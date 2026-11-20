// 3. La distancia desde la cámara (equivalente a gl_FogFragCoord)
float fogFragCoord = length(worldPos.xyz);

vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);
vec3 viewPositionNormalized = normalize(fragposition.xyz);

float invFogAdjust = 1.0 / FOG_ADJUST;
float nearFogVoxy = 0.0;

#if !defined THE_END && !defined NETHER
    float fog_density_coeff = dayBlendFloatVoxy(
        FOG_SUNSET,
        FOG_DAY,
        FOG_NIGHT,
        dayMixerV,
        nightMixerV,
        dayMomentV
    ) * invFogAdjust;

    float fog_intensity_coeff = max(eyeBrightSmoothFloat.y * 0.004166666666666667, visibleSky);
    fog_intensity_coeff = mix(0.5, 1.0, fog_intensity_coeff);
    float biome_fog = 1.0;

    float invDist = 1.0 / (vxRenderDistance * 16);
    float dist_ratio = fogFragCoord * invDist;

    vec3 dirToSun = sunPosition * 0.01; 

    float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, viewPositionNormalized));
    float sunInfluenceV = sunAngle * sunAngle * sunAngle; 
    float sunDayFactor = max(dayBlendFloatVoxyN(dayBlendFloatVoxyN(1.0, 0.1, 0.0, dayMixerV, nightMixerV, dayMomentV), 0.1, dayBlendFloatVoxyN(-10.0, 0.1, 0.0, dayMixerV, nightMixerV, dayMomentV), dayMixerV, nightMixerV, dayMomentV), 0.0);
    float dynamic_density = 0.008 + (0.001 * sunInfluenceV * sunDayFactor);
    dynamic_density *= fog_intensity_coeff;

    #ifdef NEAR_FOG
        const float FOG_H_REF       = 63.0;
        const float FOG_H_FALLOFF   = 0.01;
        const float FOG_LAYER_BOOST = 0.4;

        float py    = dot(vec3(vxModelViewInv[0].y, vxModelViewInv[1].y, vxModelViewInv[2].y), fragposition.xyz);
        float fragY = cameraPosition.y + py - FOG_H_REF;

        float heightMul = FOG_LAYER_BOOST * exp(-FOG_H_FALLOFF * max(fragY, 0.0)) * smoothstep(0.0, 0.05, dist_ratio);

        float densityMul = dynamic_density * mix(1.0, 2.5, rainStrength) * invFogAdjust;

        float x = max(0.0, fogFragCoord) * densityMul * heightMul;
        nearFogVoxy = 1.0 - exp(-x);

        float hx = fogFragCoord * dynamic_density * fog_density_coeff * mix(1.0, 6.0, rainStrength) * invFogAdjust;
        float horizon_fog = clamp(mix(1.0 - exp(-hx), 1.0 - exp(-hx * hx), mix(0.0, -1.0, rainStrength)), 0.0, 1.0);

        horizon_fog = mix(horizon_fog, 1.0, smoothstep(0.7, 1.0, clamp(dist_ratio, 0.0, 1.0)));
        float frogAdjust = max(nearFogVoxy, horizon_fog);
    #else
        float hx = fogFragCoord * dynamic_density * fog_density_coeff * mix(1.0, 6.0, rainStrength) * invFogAdjust;
        float horizon_fog = clamp(mix(1.0 - exp(-hx), 1.0 - exp(-hx * hx), mix(0.0, -1.0, rainStrength)), 0.0, 1.0);

        float frogAdjust = mix(horizon_fog, 1.0, smoothstep(0.7, 1.0, clamp(dist_ratio, 0.0, 1.0)));
    #endif
#else
    #if defined NETHER
        #if NETHER_FOG_DISTANCE == 1
            float sight = NETHER_SIGHT;
        #else
            float sight = (vxRenderDistance * 16);
        #endif
    #else
        float sight = (vxRenderDistance * 16) * 0.75;
    #endif

    float horizon_fog = fastpow(clamp(fogFragCoord / sight, 0.0, 1.0), 0.75);
    frogAdjust = max(nearFogVoxy, fastpow(horizon_fog, FOG_ADJUST * 0.25));
#endif
// 3. La distancia desde la cámara (equivalente a gl_FogFragCoord)
float fogFragCoord = length(worldPos.xyz);

vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);
vec3 viewPositionNormalized = normalize(fragposition.xyz);

float invFogAdjust = 1.0 / FOG_ADJUST;
float nearFogVoxy = 0.0;

#if !defined THE_END && !defined NETHER
    float rainMod = mix(1.0, 1.5, rainStrength);
    float fog_density_coeff = dayBlendFloatVoxy(
        FOG_SUNSET,
        FOG_DAY,
        FOG_NIGHT * rainMod,
        dayMixerV,
        nightMixerV,
        dayMomentV
    ) * FOG_ADJUST;

    float fog_intensity_coeff = 1.0;
    float biome_fog = 1.0;

    float invDist = 1.0 / (vxRenderDistance * 16);
    float dist_ratio = fogFragCoord * invDist;

    vec3 dirToSun = sunPosition * 0.01; 

    float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, viewPositionNormalized));
    float sunInfluenceV = sunAngle * sunAngle * sunAngle; 

    #ifdef NEAR_FOG
        float sunDayFactor = max(dayBlendFloatVoxyN(dayBlendFloatVoxyN(1.0, 0.1, 0.0, dayMixerV, nightMixerV, dayMomentV), 0.1, dayBlendFloatVoxyN(-10.0, 0.1, 0.0, dayMixerV, nightMixerV, dayMomentV), dayMixerV, nightMixerV, dayMomentV), 0.0);

        float dynamic_density = 0.003 + (0.001 * sunInfluenceV * sunDayFactor);

        float dist_adj = max(0.0, fogFragCoord);
        float x = dist_adj * dynamic_density * mix(1.0, 3.5, rainStrength) * invFogAdjust;
        float fogLinear = 1.0 - exp(-x);
        float fogSquared = 1.0 - exp(-x * x);
        nearFogVoxy = clamp(mix(fogLinear, fogSquared, -0.4), 0.0, 1.0);

        float horizon_exp = mix(fog_density_coeff * biome_fog, fog_density_coeff * biome_fog * 0.2, rainStrength);
        float horizon_fog = fastpow(clamp(dist_ratio * fog_intensity_coeff, 0.0, 1.0), horizon_exp);

        float frogAdjust = max(nearFogVoxy, horizon_fog);
    #else
        float horizon_exp = mix(fog_density_coeff * biome_fog, fog_density_coeff * biome_fog * 0.2, rainStrength);
        float frogAdjust = fastpow(clamp(dist_ratio * fog_intensity_coeff, 0.0, 1.0), horizon_exp);
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
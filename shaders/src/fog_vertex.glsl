float invFogAdjust = 1.0 / FOG_ADJUST;

float dist_ratio;
#if !defined THE_END && !defined NETHER
    float fog_density_coeff = dayBFlgcy(
        FOG_SUNSET,
        FOG_DAY,
        FOG_NIGHT
    ) * invFogAdjust;

    float fog_intensity_coeff = max(eye_bright_smooth.y * 0.004166666666666667, visible_sky);
    fog_intensity_coeff = mix(0.5, 1.0, fog_intensity_coeff);

    #ifdef DISTANT_HORIZONS
        float invDist = 1.0 / dhRenderDistance;
    #elif defined VOXY
        float invDist = 1.0 / vxRenderDistance / 16;
    #else
        float invDist = 1.0 / far;
    #endif
    dist_ratio = gl_FogFragCoord * invDist;

    vec3 dirToSun  = sunPosition * 0.01; 

    float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, dirToView));
    sunInfluence = sunAngle * sunAngle * sunAngle; 

    float sunDayFactor = max(dayBF(dayBF(1.0, 0.1, 0.0), 0.1, dayBF(-10.0, 0.1, 0.0)), 0.0);

    #if defined DISTANT_HORIZONS || defined VOXY
        float dynamic_density = 0.008 + (0.001 * sunInfluence * sunDayFactor);
    #else
        float dynamic_density = 0.01 + (0.004 * sunInfluence * sunDayFactor);
    #endif

    dynamic_density *= fog_intensity_coeff;

    #ifdef NEAR_FOG
        const float FOG_H_REF       = 63.0;
        const float FOG_H_FALLOFF   = 0.01;
        const float FOG_LAYER_BOOST = 0.4;

        float py    = dot(vec3(gbufferModelViewInverse[0].y, gbufferModelViewInverse[1].y, gbufferModelViewInverse[2].y), sub_position.xyz);
        float fragY = cameraPosition.y + py - FOG_H_REF;

        float heightMul = FOG_LAYER_BOOST * exp(-FOG_H_FALLOFF * max(fragY, 0.0)) * smoothstep(0.0, 0.05, dist_ratio);

        float x = max(0.0, gl_FogFragCoord) * dynamic_density * heightMul * mix(1.0, 6.0, rainStrength) * invFogAdjust;
        float near_fog = 1.0 - exp(-x);

        float hx = gl_FogFragCoord * dynamic_density * fog_density_coeff * mix(1.0, 6.0, rainStrength) * invFogAdjust;
        float horizon_fog = clamp(mix(1.0 - exp(-hx), 1.0 - exp(-hx * hx), mix(0.0, -1.0, rainStrength)), 0.0, 1.0);

        horizon_fog = mix(horizon_fog, 1.0, smoothstep(0.7, 1.0, clamp(dist_ratio, 0.0, 1.0)));
        fog_adj = max(near_fog, horizon_fog);
    #else
        float hx = gl_FogFragCoord * dynamic_density * fog_density_coeff * mix(1.0, 8.0, rainStrength) * invFogAdjust;
        float horizon_fog = clamp(mix(1.0 - exp(-hx), 1.0 - exp(-hx * hx), mix(0.0, -1.0, rainStrength)), 0.0, 1.0);

        fog_adj = mix(horizon_fog, 1.0, smoothstep(0.7, 1.0, clamp(dist_ratio, 0.0, 1.0)));
    #endif
#else
    #if defined NETHER
        #if NETHER_FOG_DISTANCE == 1
            float sight = NETHER_SIGHT;
        #else
            #if defined DISTANT_HORIZONS
                float sight = dhRenderDistance;        
            #elif defined VOXY
                float sight = (vxRenderDistance * 16);
            #else
                float sight = far;
            #endif
        #endif
    #else
        #if defined DISTANT_HORIZONS
            float sight = dhRenderDistance;
        #elif defined VOXY
            float sight = (vxRenderDistance * 16) * 0.75;
        #else
            float sight = far * 0.75;
        #endif 
    #endif

    float horizon_fog = pow(clamp(gl_FogFragCoord / sight, 0.0, 1.0), 0.75);
    fog_adj = pow(horizon_fog, FOG_ADJUST * 0.25); // Made by Tas :)
#endif

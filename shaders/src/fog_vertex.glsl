float invFogAdjust = 1.0 / FOG_ADJUST;

#if !defined THE_END && !defined NETHER
    float rainMod = mix(1.0, 1.5, rainStrength);
    float fog_density_coeff = dayBFlgcy(
        FOG_SUNSET,
        FOG_DAY,
        FOG_NIGHT * rainMod
    ) * FOG_ADJUST;

    float fog_intensity_coeff = 1.0;


    #ifdef DISTANT_HORIZONS
        float invDist = 1.0 / dhRenderDistance;
    #elif defined VOXY
        float invDist = 1.0 / vxRenderDistance / 16;
    #else
        float invDist = 1.0 / far;
    #endif
    float dist_ratio = gl_FogFragCoord * invDist;

    vec3 dirToSun  = sunPosition * 0.01; 

    float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, dirToView));
    sunInfluence = sunAngle * sunAngle * sunAngle; 

    #ifdef NEAR_FOG
        float sunDayFactor = dayBF(1.0, 0.1, 0.0);

        #if defined DISTANT_HORIZONS || defined VOXY
            float dynamic_density = 0.002 + (0.001 * sunInfluence * sunDayFactor);
        #else
            float dynamic_density = 0.004 + (0.005 * sunInfluence * sunDayFactor);
        #endif

        #if defined VOXY
            float dist_adj = max(0.0, gl_FogFragCoord - (float(vxRenderDistance * 16) / mix(24.0, 240.0, rainStrength)));
            near_fog = clamp(1.0 - exp(-dist_adj * dynamic_density * mix(1.0, 2.5, rainStrength) * invFogAdjust), 0.0, 1.0);
        #elif defined DISTANT_HORIZONS
            float dist_adj = (gl_FogFragCoord - (dhRenderDistance / mix(30.0, 240.0, rainStrength)));
            near_fog = clamp(1.0 - exp(-dist_adj * dynamic_density * mix(1.0, 2.5, rainStrength) * invFogAdjust), 0.0, 1.0);
        #else
            float dist_adj = (gl_FogFragCoord - (far / mix(7.0, 25.0, rainStrength)));
            near_fog = clamp(1.0 - exp(-dist_adj * dynamic_density * mix(1.0, 2.5, rainStrength) * invFogAdjust), 0.0, 1.0);
        #endif
        float horizon_exp = mix(fog_density_coeff * biome_fog, fog_density_coeff * biome_fog * 0.2, rainStrength);
        float horizon_fog = pow(clamp(dist_ratio * fog_intensity_coeff, 0.0, 1.0), horizon_exp);

        fog_adj = max(near_fog, horizon_fog);
    #else
        float horizon_exp = mix(fog_density_coeff * biome_fog, fog_density_coeff * biome_fog * 0.2, rainStrength);
        fog_adj = pow(clamp(dist_ratio * fog_intensity_coeff, 0.0, 1.0), horizon_exp);
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

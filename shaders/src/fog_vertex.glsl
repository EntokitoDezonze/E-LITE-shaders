float invFogAdjust = 1.0 / FOG_ADJUST;

#if !defined THE_END && !defined NETHER
    float rainMod = mix(1.0, 1.5, rainStrength);
    float fog_density_coeff = day_blend_float_lgcy(
        FOG_SUNSET,
        FOG_DAY,
        FOG_NIGHT * rainMod
    ) * FOG_ADJUST;

    float fog_intensity_coeff = 1.0;


    #ifdef DISTANT_HORIZONS
        float invDist = 1.0 / dhRenderDistance;
    #else
        float invDist = 1.0 / far;
    #endif
    float dist_ratio = gl_FogFragCoord * invDist;

    vec3 dirToSun  = sunPosition * 0.01; 

    float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, dirToView));
    sunInfluence = sunAngle * sunAngle * sunAngle; 

    #ifdef NEAR_FOG
        float sunDayFactor = day_blend_float(1.0, 0.1, 0.0);

        #ifdef DISTANT_HORIZONS
            float dynamic_density = 0.002 + (0.001 * sunInfluence * sunDayFactor);
        #else
            float dynamic_density = 0.004 + (0.005 * sunInfluence * sunDayFactor);
        #endif

        float dist_adj = (gl_FogFragCoord - (far / 7));
        near_fog = clamp(1.0 - exp(-dist_adj * dynamic_density * invFogAdjust), 0.0, 1.0);
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
            #else
                float sight = clamp(NETHER_SIGHT * FOG_ADJUST * 0.25, 0.0, far);
            #endif
        #endif
        float density = 0.1;
    #else
        #if defined DISTANT_HORIZONS
            float sight = dhRenderDistance;
        #else
            float sight = far * 0.75;
        #endif
        float density = 0.005;
    #endif
    
    #ifdef NEAR_FOG
        float dist_adj = max(0.0, gl_FogFragCoord - (sight * 0.3));
        near_fog = clamp(1.0 - exp(-dist_adj * density * invFogAdjust), 0.0, 1.0);
    #else
        near_fog = 0.0;
    #endif

    fog_adj = max(near_fog, sqrt(clamp(gl_FogFragCoord / sight, 0.0, 1.0)));
#endif

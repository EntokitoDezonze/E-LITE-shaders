#if !defined THE_END && !defined NETHER
    float fog_intensity_coeff = max(eye_bright_smooth.y * 0.004166666666666667, visible_sky);

    float invFogAdjust = 1.0 / FOG_ADJUST;

    #ifdef DISTANT_HORIZONS
        float dist_ratio = gl_FogFragCoord / dhRenderDistance;
    #else
        float dist_ratio = gl_FogFragCoord / far;
    #endif

    #ifdef NEAR_FOG
        vec3 dirToView = normalize(sub_position.xyz);
        vec3 dirToSun  = sunPosition * 0.01; 

        float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, dirToView));
        float sunInfluence = sunAngle * sunAngle * sunAngle; 

        float sunDayFactor = dayBF(1.0, 0.1, 0.0);
        float dynamic_density = 0.002 + (0.001 * sunInfluence * sunDayFactor);

        float dist_adj = (gl_FogFragCoord - (dhRenderDistance / mix(30.0, 240.0, rainStrength)));
        near_fog = clamp(1.0 - exp(-dist_adj * dynamic_density * mix(1.0, 2.5, rainStrength) * invFogAdjust), 0.0, 1.0);
        float horizon_exp = mix(fog_density_coeff * biome_fog, fog_density_coeff * biome_fog * 0.2, rainStrength);
        float horizon_fog = pow(clamp(dist_ratio * fog_intensity_coeff, 0.0, 1.0), horizon_exp);

        fog_adj = max(near_fog, horizon_fog);
    #else
        float horizon_exp = mix(fog_density_coeff * biome_fog, fog_density_coeff * biome_fog * 0.2, rainStrength);
        fog_adj = pow(clamp(dist_ratio * fog_intensity_coeff, 0.0, 1.0), horizon_exp);
    #endif
#else
    float horizon_fog = pow(clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0), 0.75);
    fog_adj = pow(horizon_fog, FOG_ADJUST * 0.25);
#endif
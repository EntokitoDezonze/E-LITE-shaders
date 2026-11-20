#if !defined THE_END && !defined NETHER
    float fog_intensity_coeff = max(eye_bright_smooth.y * 0.004166666666666667, visible_sky);

    float invFogAdjust = 1.0 / FOG_ADJUST;

    dist_ratio = gl_FogFragCoord / dhRenderDistance;

    vec3 dirToView = normalize(sub_position.xyz);
    vec3 dirToSun  = sunPosition * 0.01; 

    float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, dirToView));
    float sunInfluence = sunAngle * sunAngle * sunAngle; 

    float sunDayFactor = max(dayBF(dayBF(1.0, 0.1, 0.0), 0.1, dayBF(-10.0, 0.1, 0.0)), 0.0);
    float dynamic_density = 0.008 + (0.001 * sunInfluence * sunDayFactor);
    dynamic_density *= fog_intensity_coeff;

    #ifdef NEAR_FOG
        const float FOG_H_REF       = 63.0;
        const float FOG_H_FALLOFF   = 0.01;
        const float FOG_LAYER_BOOST = 0.4;

        float dist_adj = max(0.0, gl_FogFragCoord);
        float py    = dot(vec3(gbufferModelViewInverse[0].y, gbufferModelViewInverse[1].y, gbufferModelViewInverse[2].y), sub_position.xyz);
        float fragY = cameraPosition.y + py - FOG_H_REF;

        float layer     = exp(-FOG_H_FALLOFF * max(fragY, 0.0));
        float farFactor = smoothstep(0.0, 0.05, dist_ratio);
        float heightMul = FOG_LAYER_BOOST * layer * farFactor;

        float x = dist_adj * dynamic_density * heightMul * mix(1.0, 8.0, rainStrength) * invFogAdjust;
        float near_fog = 1.0 - exp(-x);
        float hx = gl_FogFragCoord * dynamic_density * fog_density_coeff * mix(1.0, 6.0, rainStrength) * invFogAdjust;
        float horizon_fog = clamp(mix(1.0 - exp(-hx), 1.0 - exp(-hx * hx), mix(0.0, -1.0, rainStrength)), 0.0, 1.0);

        horizon_fog = mix(horizon_fog, 1.0, smoothstep(0.7, 1.0, clamp(dist_ratio, 0.0, 1.0)));
        fog_adj = max(near_fog, horizon_fog);
    #else
        float hx = gl_FogFragCoord * dynamic_density * fog_density_coeff * mix(1.0, 6.0, rainStrength) * invFogAdjust;
        float horizon_fog = clamp(mix(1.0 - exp(-hx), 1.0 - exp(-hx * hx), mix(1.0, -1.0, rainStrength)), 0.0, 1.0);

        fog_adj = mix(horizon_fog, 1.0, smoothstep(0.7, 1.0, clamp(dist_ratio, 0.0, 1.0)));
    #endif
#else
    float horizon_fog = pow(clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0), 0.75);
    fog_adj = pow(horizon_fog, FOG_ADJUST * 0.25);
#endif
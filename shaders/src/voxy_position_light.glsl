// -- Position Vertex

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float fogDensityCoeff = FOG_DENSITY * FOG_ADJUST;
    #else
        float fogDensityCoeff = dayBlendFloatVoxy(
            FOG_SUNSET,
            FOG_DAY,
            FOG_NIGHT,
            dayMixerV,
            nightMixerV,
            dayMomentV
        ) * FOG_ADJUST;
    #endif

    // ---- Original Light Vertex Logic

    // Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
    #if defined THE_END || defined NETHER
        vec2 illumination = vec2(lmcoord.x, 1.0);
    #else
        vec2 illumination = lmcoord;
    #endif

    illumination.y *= 1.06951871657754;
    float visibleSky = clamp(illumination.y, 0.0, 1.0);

    #if defined UNKNOWN_DIM
        visibleSky = (visibleSky * 0.6) + 0.4;
    #endif

    float ix = lmcoord.x;
    float l_pow = 1.17;
    #if defined GBUFFER_ENTITIES
        l_pow = 0.9;
    #endif

    float ix2 = ix * ix * l_pow;
    float ix4 = ix2 * ix2;
    float ix8 = ix4 * ix4;
    float ix15 = ix8 * ix4 * ix2 * ix;

    #if COLOR_SCHEME == 5
        vec3 candleColor = CANDLE_BASELIGHT * (ix + ix8);
    #else
        vec3 candleColor = CANDLE_BASELIGHT * (ix2 * ix15 + ix * sqrt(ix));
    #endif

    // Atenuación por dirección de luz directa ===================================
    #if defined THE_END || defined NETHER
        vec3 astroVector = normalize(vxModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
    #else
        vec3 astroVector = normalize(sunPosition);
        float rain_mul = dayBlendFloatVoxyN(dayBlendFloatVoxyN(0.7, 0.5, 1.0, dayMixerV, nightMixerV, dayMomentV), 0.175, dayBlendFloatVoxyN(1.8, 1.0, 1.0, dayMixerV, nightMixerV, dayMomentV), dayMixerV, nightMixerV, dayMomentV);
        #if COLOR_SCHEME == 4
            rain_mul = dayBlendFloatVoxyN(0.5, 0.4, 0.4, dayMixerV, nightMixerV, dayMomentV);
        #endif
        float dayBlendSunset = 1.0;
    #endif

    vec3 normal = vec3(uint((face>>1)==2), uint((face>>1)==0), uint((face>>1)==1)) * (float(int(face)&1)*2-1);
    float astroLightStrength;

    #if defined THE_END || defined NETHER
        vec3 sun_vec = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
    #else
        vec3 sun_vec = sunPosition * 0.01;
    #endif

    vec3 sunWorldVec = normalize(mat3(vxModelViewInv) * sun_vec);
    float ydotl = clamp(sunWorldVec.y, 0.0, 1.0);
    
    if (dot(normal, normal) > 0.0001) {
        normal = normalize(normal);
        float ndotl = dot(normal, sunWorldVec);

        astroLightStrength = clamp((ndotl + dayBlendFloatVoxyN(0.2, 0.2, 0.0, dayMixerV, nightMixerV, dayMomentV) * step(0.01, ndotl)), -1.0, 1.0);
    } else {
        normal = vec3(0.0, 1.0, 0.0);
        astroLightStrength = 1.0;
    }
    normal = mat3(vxModelView) * normal;

    #if defined THE_END || defined NETHER
        float directLightStrength = astroLightStrength;
    #else
        float directLightStrength = mix(-astroLightStrength, astroLightStrength, dayNightMix);
    #endif

    // Omni light intensity changes by angle
    float omniStrength = (directLightStrength * 0.05) + 1.0;

    // Calculamos color de luz directa
    #if defined UNKNOWN_DIM
        vec3 directLightColor = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb;
    #else
        vec3 directLightColor = dayBlendVoxy(
            LIGHT_SUNSET_COLOR * dayBlendFloatVoxyN(0.85, 1.0, 0.0, dayMixerV, nightMixerV, dayMomentV),  
            LIGHT_DAY_COLOR * dayBlendFloatVoxyN(1.17, 1.1, 1.0, dayMixerV, nightMixerV, dayMomentV) * mix(1.5 - ydotl, 1.0, rainStrength), 
            LIGHT_NIGHT_COLOR * dayBlendFloatVoxyN(1.0, 1.0, 1.45, dayMixerV, nightMixerV, dayMomentV),
            dayMixerV,
            nightMixerV,
            dayMomentV
        );
        #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
            directLightColor += (endFlashIntensity * endFlashIntensity * 0.05);
        #endif
    #endif
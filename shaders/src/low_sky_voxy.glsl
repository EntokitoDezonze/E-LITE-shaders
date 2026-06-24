#ifdef UNKNOWN_DIM
    vec3 horizonSkyColorRGB = fogColor;
    vec3 horizonSkyColor = rgbToXyz(horizonSkyColorRGB);
#else
    #if COLOR_SCHEME == 2
        vec3 horizonSkyColorRGB = dayBlendVoxyN(
            HORIZON_SUNSET_COLOR * dayBlendVoxyN(vec3(1.0), vec3(1.0, 1.5, 1.0), vec3(2.0, 1.5, 0.8), dayMixerV, nightMixerV, dayMomentV),
            HORIZON_DAY_COLOR,
            HORIZON_NIGHT_COLOR,
            dayMixerV,
            nightMixerV,
            dayMomentV
        );

        horizonSkyColorRGB = mix(
            horizonSkyColorRGB,
            HORIZON_SKY_RAIN_COLOR * luma(horizonSkyColorRGB) * dayBlendFloatVoxy(0.5, 0.4, 0.75, dayMixerV, nightMixerV, dayMomentV),
            rainStrength
        );

        vec3 horizonSkyColor = rgbToXyz(horizonSkyColorRGB);
    #else
        vec3 horizonSkyColorRGB = dayBlendVoxy(
            HORIZON_SUNSET_COLOR,
            HORIZON_DAY_COLOR,
            HORIZON_NIGHT_COLOR,
            dayMixerV,
            nightMixerV,
            dayMomentV
        );

        #if COLOR_SCHEME == 4
            horizonSkyColorRGB = mix(
                horizonSkyColorRGB,
                HORIZON_SKY_RAIN_COLOR * luma(horizonSkyColorRGB) * 3.333,
                rainStrength
            );
        #else
            horizonSkyColorRGB = mix(
                horizonSkyColorRGB,
                HORIZON_SKY_RAIN_COLOR * luma(horizonSkyColorRGB),
                rainStrength
            );
        #endif

        vec3 horizonSkyColor = rgbToXyz(horizonSkyColorRGB);
    #endif
#endif
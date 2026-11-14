#ifdef UNKNOWN_DIM
    vec3 horizonSkyColorRGB = fogColor;
    vec3 horizonSkyColor = rgbToOklab(horizonSkyColorRGB);
#else
    #if COLOR_SCHEME == 2
        vec3 horizonSkyColorRGB = dayBlendVoxyN(
            HORIZON_SUNSET_COLOR * dayBlendVoxyN(vec3(1.0), vec3(1.0, 1.5, 1.0), dayBlendVoxy(vec3(1.0, 1.5, 0.0), vec3(1.0), vec3(1.8, 1.25, 0.5), dayMixerV, nightMixerV, dayMomentV), dayMixerV, nightMixerV, dayMomentV),
            HORIZON_DAY_COLOR,
            HORIZON_NIGHT_COLOR,
            dayMixerV,
            nightMixerV,
            dayMomentV
        );

        horizonSkyColorRGB = mix(
            horizonSkyColorRGB,
            HORIZON_SKY_RAIN_COLOR * luma(horizonSkyColorRGB) * dayBlendFloatVoxy(0.5, 0.5, 0.75, dayMixerV, nightMixerV, dayMomentV),
            rainStrength
        );

        vec3 horizonSkyColor = rgbToOklab(horizonSkyColorRGB);
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

        vec3 horizonSkyColor = rgbToOklab(horizonSkyColorRGB);
    #endif
#endif

vec3 pure_low_sky_color_rgb = dayBlendVoxy(
    HORIZON_SUNSET_COLOR,
    HORIZON_DAY_COLOR,
    HORIZON_NIGHT_COLOR,
    dayMixerV,
    nightMixerV,
    dayMomentV
);

pure_low_sky_color_rgb = mix(
    pure_low_sky_color_rgb,
    HORIZON_SKY_RAIN_COLOR * luma(pure_low_sky_color_rgb) * dayBlendFloatVoxyN(1.0, 1.0, 1.5, dayMixerV, nightMixerV, dayMomentV),
    (rainStrength - 0.05)
);

vec3 pure_low_sky_color = rgbToOklab(pure_low_sky_color_rgb);
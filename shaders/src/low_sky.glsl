#ifdef UNKNOWN_DIM
    vec3 low_sky_color_rgb = fogColor;
    low_sky_color = rgbToXyz(low_sky_color_rgb);
#else
    #if COLOR_SCHEME == 2
    vec3 low_sky_color_rgb = dayBlend(
            HORIZON_SUNSET_COLOR * dayBlend(vec3(1.0), vec3(1.0, 1.5, 1.0), vec3(2.0, 1.5, 0.8)),
            HORIZON_DAY_COLOR,
            HORIZON_NIGHT_COLOR
        );

        low_sky_color_rgb = mix(
            low_sky_color_rgb,
            HORIZON_SKY_RAIN_COLOR * luma(low_sky_color_rgb) * dayBF(0.5, 0.4, 0.75),
            rainStrength
        );

        low_sky_color = rgbToXyz(low_sky_color_rgb);
    #else
    vec3 low_sky_color_rgb = dayBlend(
            HORIZON_SUNSET_COLOR,
            HORIZON_DAY_COLOR,
            HORIZON_NIGHT_COLOR
        );

        #if COLOR_SCHEME == 4
            low_sky_color_rgb = mix(
                low_sky_color_rgb,
                HORIZON_SKY_RAIN_COLOR * luma(low_sky_color_rgb) * 3.333,
                rainStrength
            );
        #else
            low_sky_color_rgb = mix(
                low_sky_color_rgb,
                HORIZON_SKY_RAIN_COLOR * luma(low_sky_color_rgb),
                rainStrength
            );
        #endif

        low_sky_color = rgbToXyz(low_sky_color_rgb);
    #endif
#endif

vec3 pure_low_sky_color_rgb = dayBlend(
        HORIZON_SUNSET_COLOR,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR
    );

    pure_low_sky_color_rgb = mix(
        pure_low_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(pure_low_sky_color_rgb) * dayBF(1.0, 1.0, 1.5),
        (rainStrength - 0.05)
    );

    pure_low_sky_color = rgbToXyz(pure_low_sky_color_rgb);
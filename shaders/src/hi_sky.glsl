#ifdef UNKNOWN_DIM
    vec3 hi_sky_color_rgb = skyColor;
    hi_sky_color = rgbToXyz(hi_sky_color_rgb);
#else
    #if COLOR_SCHEME == 2
    vec3 hi_sky_color_rgb = dayBlend(
            saturate(ZENITH_SUNSET_COLOR, dayBFlgcy(1.0, 1.0, 1.5)) * dayBlend(vec3(1.0), vec3(1.0), vec3(0.25)),
            ZENITH_DAY_COLOR,
            saturate(ZENITH_NIGHT_COLOR, 0.25)
        );

        hi_sky_color_rgb = mix(
            hi_sky_color_rgb,
            ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb) * dayBF(1.0, 0.45, dayBF(1.75, 0.45, 1.25)),
            rainStrength
        );

        hi_sky_color = rgbToXyz(hi_sky_color_rgb);
    #else
        vec3 hi_sky_color_rgb = dayBlend(
            ZENITH_SUNSET_COLOR,
            ZENITH_DAY_COLOR,
            ZENITH_NIGHT_COLOR
        );

        #if COLOR_SCHEME == 4
            hi_sky_color_rgb = mix(
                hi_sky_color_rgb,
                ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb) * 0.333,
                rainStrength
            );
        #else
            hi_sky_color_rgb = mix(
                hi_sky_color_rgb,
                ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb),
                rainStrength
            );
        #endif

        hi_sky_color = rgbToXyz(hi_sky_color_rgb);
    #endif
#endif

vec3 pure_hi_sky_color_rgb = dayBlend(
        ZENITH_SUNSET_COLOR,
        ZENITH_DAY_COLOR,
        saturate(ZENITH_NIGHT_COLOR, 0.5)
    );

    pure_hi_sky_color_rgb = mix(
        pure_hi_sky_color_rgb,
        ZENITH_SKY_RAIN_COLOR * luma(pure_hi_sky_color_rgb),
        rainStrength
    );

    pure_hi_sky_color = rgbToXyz(pure_hi_sky_color_rgb);
#if COLOR_SCHEME == 2
vec3 mid_sky_color_rgb = dayBlend(
        saturate(MID_SUNSET_COLOR, dayBFlgcy(1.0, 1.0, 0.25)) * dayBlend(vec3(1.0), vec3(1.0), vec3(2.0)),
        MID_DAY_COLOR,
        saturate(MID_NIGHT_COLOR, dayBF(1.0, 1.0, 0.0)) * dayBF(1.0, 1.0, 1.25)
    );

    mid_sky_color_rgb = mix(
        mid_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(mid_sky_color_rgb * dayBF(1.0, 0.5, 0.75)),
        rainStrength
    );

    mid_sky_color = rgbToXyz(mid_sky_color_rgb);
#else
vec3 mid_sky_color_rgb = dayBlend(
        MID_SUNSET_COLOR,
        MID_DAY_COLOR,
        MID_NIGHT_COLOR
    );

    mid_sky_color_rgb = mix(
        mid_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(mid_sky_color_rgb),
        rainStrength
    );

    mid_sky_color = rgbToXyz(mid_sky_color_rgb );
#endif

vec3 pure_mid_sky_color_rgb = dayBlend(
        saturate(MID_SUNSET_COLOR, 0.5),
        MID_DAY_COLOR,
        MID_NIGHT_COLOR
    );

    pure_mid_sky_color_rgb = mix(
        pure_mid_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(pure_mid_sky_color_rgb) * dayBF(1.0, 0.66, 2.0),
        (rainStrength - 0.05)
    );

    pure_mid_sky_color = rgbToXyz(pure_mid_sky_color_rgb);
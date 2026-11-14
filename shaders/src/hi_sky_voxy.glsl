#ifdef UNKNOWN_DIM
    vec3 ZenithSkyColorRGB = skyColor;
    vec3 zenithSkyColor = rgbToOklab(ZenithSkyColorRGB);
#else
    vec3 ZenithSkyColorRGB = dayBlendVoxyN(
        ZENITH_SUNSET_COLOR,
        ZENITH_DAY_COLOR,
        ZENITH_NIGHT_COLOR,
        dayMixerV,
        nightMixerV,
        dayMomentV
    );

    ZenithSkyColorRGB = mix(
        ZenithSkyColorRGB,
        ZENITH_SKY_RAIN_COLOR * saturate(ZenithSkyColorRGB, -0.01) * dayBlendFloatVoxy(1.0, 0.9, dayBlendFloatVoxy(1.75, 0.45, 1.25, dayMixerV, nightMixerV, dayMomentV), dayMixerV, nightMixerV, dayMomentV),
        rainStrength
    );

    vec3 pure_hi_sky_color_rgb = dayBlendVoxyN(
        saturate(ZENITH_SUNSET_COLOR, dayBF(1.0, 1.0, 0.0)),
        ZENITH_DAY_COLOR,
        saturate(ZENITH_NIGHT_COLOR, 0.5),
        dayMixerV,
        nightMixerV,
        dayMomentV
    );

    pure_hi_sky_color_rgb = mix(
        pure_hi_sky_color_rgb,
        ZENITH_SKY_RAIN_COLOR * luma(pure_hi_sky_color_rgb),
        rainStrength
    );

    vec3 zenithSkyColor = rgbToOklab(ZenithSkyColorRGB);
    vec3 pure_hi_sky_color = rgbToOklab(pure_hi_sky_color_rgb);
#endif



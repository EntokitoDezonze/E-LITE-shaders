#ifdef UNKNOWN_DIM
    vec3 ZenithSkyColorRGB = skyColor;
    vec3 zenithSkyColor = rgbToXyz(ZenithSkyColorRGB);
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
        ZENITH_SKY_RAIN_COLOR * luma(ZenithSkyColorRGB) * dayBlendFloatVoxy(1.0, 0.75, dayBlendFloatVoxy(2.0, 1.0, 1.25, dayMixerV, nightMixerV, dayMomentV), dayMixerV, nightMixerV, dayMomentV),
        rainStrength
    );

    vec3 zenithSkyColor = rgbToXyz(ZenithSkyColorRGB);
#endif
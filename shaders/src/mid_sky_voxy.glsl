#ifdef UNKNOWN_DIM
    vec3 pure_mid_sky_color = skyColor;
    vec3 pure_mid_sky_color = rgbToXyz(pure_mid_sky_color);
#else
    vec3 pure_mid_sky_color = dayBlendVoxyN(
        saturate(MID_SUNSET_COLOR, 0.5) * dayBlendFloatVoxy(1.0, 1.0, 0.95, dayMixerV, nightMixerV, dayMomentV),
        MID_DAY_COLOR,
        MID_NIGHT_COLOR,
        dayMixerV,
        nightMixerV,
        dayMomentV
    );

    pure_mid_sky_color = mix(
        pure_mid_sky_color,
        HORIZON_SKY_RAIN_COLOR * luma(pure_mid_sky_color * 1.25) * dayBlendFloatVoxy(1.0, 0.666, 2.0, dayMixerV, nightMixerV, dayMomentV),
        rainStrength - 0.05
    );

    pure_mid_sky_color = rgbToXyz(pure_mid_sky_color);
#endif
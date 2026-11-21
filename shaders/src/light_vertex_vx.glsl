#if defined THE_END || defined NETHER
    #ifdef THE_END
        vec3 omniLight = LIGHT_DAY_COLOR * 2.0;
    #else
        vec3 omniLight = vec3(0.05 + 0.2 * step(49.0, AVOID_DARK_LEVEL));
    #endif
#else
    directLightColor = mix(directLightColor, LIGHT_RAIN_COLOR * luma(directLightColor) * rain_mul, rainStrength);
    float isUpside = 1.0 - smoothstep(0.51, 0.75, normal.y);

    #if COLOR_SCHEME == 2 || COLOR_SCHEME == 6
        #ifndef SHADOW_CASTING
            normal.y = normal.y * 0.5 + 0.5;
        #endif
        vec3 omniColor = saturate(mix(ZenithSkyColorRGB * mix(dayBlendFloatVoxyN(3.0, 4.25, 3.0, dayMixerV, nightMixerV, dayMomentV), dayBlendFloatVoxyN(10.0, 11.0, 8.0, dayMixerV, nightMixerV, dayMomentV), rainStrength) * dayBlendSunset * mix(1.0, normal.y * 0.15 + 1.0, visibleSky * isUpside) * OMNI_MUL, directLightColor * dayBlendFloatVoxyN(1.0, 0.35, 4.0, dayMixerV, nightMixerV, dayMomentV) * OMNI_MUL, OMNI_TINT), 0.28);
    #elif COLOR_SCHEME == 4
        vec3 omniColor = directLightColor * (OMNI_MUL + dayBlendFloatVoxy(0.1, 0.1, 0.5, dayMixerV, nightMixerV, dayMomentV));
    #else
        vec3 omniColor = mix(ZenithSkyColorRGB, directLightColor * 0.45, OMNI_TINT) * (OMNI_MUL + 0.7);
    #endif

    #ifdef SIMPLE_AUTOEXP
        float lumaRatio = clamp(AVOID_DARK_LEVEL / (luma(omniColor) * 100.0), 0.25, 10.0);
    #else
        float lumaRatio = clamp(AVOID_DARK_LEVEL / (luma(omniColor) * 100.0), 0.0, 10.0);
    #endif
    vec3 omniColorMin = omniColor * lumaRatio;

    #if COLOR_SCHEME != 5
        float mask = clamp((1.0 - visibleSky) + rainStrength + step(49.0, AVOID_DARK_LEVEL), 0.0, 1.0);
        omniColorMin *= mix(dayBlendFloatVoxy(7.5, 15.0, 3.75, dayMixerV, nightMixerV, dayMomentV) * OMNI_MUL, 1.0, mask);
    #endif

    omniColorMin *= dayBlendFloatVoxy(1.0, 1.0, 0.25 + 0.75 * (step(49.0, AVOID_DARK_LEVEL)), dayMixerV, nightMixerV, dayMomentV);

    #if COLOR_SCHEME != 5
        omniColor = clamp(omniColor, AVOID_DARK_LEVEL * 0.01, 10.0);
    #else
        omniColor = clamp(omniColor, AVOID_DARK_LEVEL * 0.0025, 10.0);
    #endif

    #ifdef SIMPLE_AUTOEXP
        omniColorMin = mix(omniColorMin / max(luma(omniColorMin), 0.001) * 0.15 + 0.05 * step(49.0, AVOID_DARK_LEVEL), omniColorMin, visibleSky);
    #else
        omniColorMin = mix(omniColorMin / max(luma(omniColorMin), 0.001) * 0.025 + 0.2 * step(49.0, AVOID_DARK_LEVEL), omniColorMin, visibleSky);
    #endif

    vec3 omniLight = mix(omniColorMin, omniColor, visibleSky * visibleSky) * omniStrength;
#endif

#if !defined THE_END && !defined NETHER
    #ifndef SHADOW_CASTING
        if (isEyeInWater == 0) {
            float visSky2 = visibleSky * visibleSky;
            directLightStrength = mix(0.0, directLightStrength, visSky2 * visibleSky);
        } else {
            directLightStrength = mix(0.0, directLightStrength, visibleSky);
        }
    #else
        directLightStrength *= visibleSky;
    #endif
#endif

if (customId > 6999.5 && customId < 7017.5) {
    directLightStrength = 1.0;
}

if (customId > 10018.5 && customId < 10019.5) {
    directLightStrength = sqrt(directLightStrength * 0.75 + 0.1);
}
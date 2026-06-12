#ifdef FOG_ACTIVE
    #if defined THE_END
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            blockColor.rgb = mix(blockColor.rgb, ZENITH_DAY_COLOR * 1.1 * vec3(1.2, 1.3, 1.2), frogAdjust);
        }
    #elif defined NETHER
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            blockColor.rgb = mix(blockColor.rgb, mix(fogColor * 0.25, vec3(0.5), 0.025), frogAdjust);
        }
    #else
        #if COLOR_SCHEME != 5
            #if VOL_LIGHT < 1 && V_CLOUDS > 0
                float fogInfluence = dayBlendFloatVoxyN(mix(1.0, 1.333, pow(sunInfluenceV, 0.333)), mix(1.01, 1.333, pow(sunInfluenceV, 0.333)), 1.0, dayMixerV, nightMixerV, dayMomentV);
            #elif VOL_LIGHT > 0 && V_CLOUDS < 1
                float fogInfluence = 1.0;
            #elif VOL_LIGHT > 0 && V_CLOUDS > 0
                float fogInfluence = dayBlendFloatVoxyN(mix(1.0, 1.11, fastpow(sunInfluenceV, 6.0)), 1.0, 1.0, dayMixerV, nightMixerV, dayMomentV);
            #else
                float fogInfluence = dayBlendFloatVoxyN(mix(1.0, 1.11, fastpow(sunInfluenceV, 6.0)), 1.0, 1.0, dayMixerV, nightMixerV, dayMomentV);
            #endif
        #else
            float fogInfluence = 1.0;
        #endif

        #if FOG_TINT == 0
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), 0.5), vec3(1.0), frogAdjust);
        #elif FOG_TINT == 1
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), 1.0), vec3(1.0), frogAdjust);
        #elif FOG_TINT == 2
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), -0.5), vec3(1.0), frogAdjust);
        #endif

        fogColorMod = saturate(fogColorMod, mix(1.0, 0.0, rainStrength));

        #if MC_VERSION >= 11900
            vec3 fog_texture;
            if(darknessFactor > .01) {
                fog_texture = vec3(0.0);
            } else {
                fog_texture = textureLod(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY), 0.0).rgb * fogInfluence * fogColorMod;
            }
        #else
            vec3 fog_texture = textureLod(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY), 0.0).rgb * fogInfluence * fogColorMod;
        #endif

        #if defined GBUFFER_ENTITIES
            if(isEyeInWater == 0 && entityId != 10101 && FOG_ADJUST < 15.0) {  // In the air
                blockColor.rgb = mix(blockColor.rgb, fog_texture, frogAdjust);
            }
        #else
            if(isEyeInWater == 0) {  // In the air
                blockColor.rgb = mix(blockColor.rgb, fog_texture, frogAdjust);
            }
        #endif
    #endif
#endif

#if MC_VERSION >= 11900
    if(blindness > .01 || darknessFactor > .01) {
        blockColor.rgb = mix(blockColor.rgb, vec3(0.0), max(blindness, darknessLightFactor) * fogFragCoord * 0.0);
    }
#else
    if(blindness > .01) {
        blockColor.rgb = mix(blockColor.rgb, vec3(0.0), blindness * fogFragCoord * 0.2);
    }
#endif
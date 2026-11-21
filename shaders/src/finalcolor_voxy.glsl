#ifdef FOG_ACTIVE
    #if defined THE_END
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            blockColor.rgb = mix(blockColor.rgb, ZENITH_DAY_COLOR * 1.1 * vec3(1.2, 1.3, 1.2), frogAdjust);
        }
    #elif defined NETHER
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            blockColor.rgb = mix(blockColor.rgb, mix(fogColor * 0.5, vec3(1.0), -0.025), frogAdjust);
        }
    #else
        #if COLOR_SCHEME != 5
            #if VOL_LIGHT < 1 && V_CLOUDS > 0
                float fogInfluence = dayBlendFloatVoxyN(mix(1.0, 1.333, pow(sunInfluenceV, 0.333)), mix(1.01, 1.333, pow(sunInfluenceV, 0.333)), 1.0, dayMixerV, nightMixerV, dayMomentV);
            #elif VOL_LIGHT > 0 && V_CLOUDS < 1
                float fogInfluence = dayBlendFloatVoxyN(mix(1.0, 1.11, fastpow(sunInfluenceV, 6.0)), 1.0, 1.0, dayMixerV, nightMixerV, dayMomentV);
            #elif VOL_LIGHT > 0 && V_CLOUDS > 0
                float fogInfluence = dayBlendFloatVoxyN(mix(1.0, 1.11, fastpow(sunInfluenceV, 6.0)), 1.0, 1.0, dayMixerV, nightMixerV, dayMomentV);
            #else
                float fogInfluence = dayBlendFloatVoxyN(mix(1.0, 1.11, fastpow(sunInfluenceV, 6.0)), 1.0, 1.0, dayMixerV, nightMixerV, dayMomentV);
            #endif
        #else
            float fogInfluence = 1.0;
        #endif

        vec3 fogColorMod = dayBlendVoxy(vec3(0.1529, 0.1725, 0.2), vec3(0.32, 0.48, 0.8) * (1.0 + frogAdjust), vec3(0.0235, 0.0314, 0.0431),
            dayMixerV,
            nightMixerV,
            dayMomentV
        );
        
        #if FOG_TINT == 0
            fogColorMod = saturate(fogColorMod, 0.5);
        #elif FOG_TINT == 1
            fogColorMod = saturate(fogColorMod, 1.0);
        #elif FOG_TINT == 2
            fogColorMod = saturate(fogColorMod, -0.5);
        #endif
    
        fogColorMod = mix(fogColorMod, saturate(fogColorMod * vec3(0.8, 0.975, 1.0) * 0.5, 0.5), rainStrength);
        float fogmix = pow(frogAdjust, 10);

        #if MC_VERSION >= 11900
            vec3 fog_texture;
            if(darknessFactor > .01) {
                fog_texture = vec3(0.0);
            } else {
                fog_texture = mix(fogColorMod, texture2D(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY)).rgb, fogmix);
            }
        #else
            vec3 fog_texture = mix(fogColorMod, texture2D(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY)).rgb, fogmix);
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
        blockColor.rgb = mix(blockColor.rgb, vec3(0.0), max(blindness, darknessLightFactor) * fogFragCoord * 0.2);
    }
#else
    if(blindness > .01) {
        blockColor.rgb = mix(blockColor.rgb, vec3(0.0), blindness * fogFragCoord * 0.2);
    }
#endif
#if defined THE_END
    #ifdef FOG_ACTIVE
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            block_color.rgb = mix(block_color.rgb, ZENITH_DAY_COLOR * 1.1 * vec3(1.2, 1.3, 1.2), fog_adj);
        }
    #endif
#elif defined NETHER
    #ifdef FOG_ACTIVE
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            block_color.rgb = mix(block_color.rgb, mix(fogColor * 0.25, vec3(0.5), 0.025), fog_adj);
        }
    #endif
#else
    #ifdef FOG_ACTIVE  // Fog active
        #if COLOR_SCHEME != 5
            #if VOL_LIGHT < 1 && V_CLOUDS > 0
                float fogInfluence = dayBF(mix(1.0, 1.333, pow(sunInfluence, 0.333)), mix(1.01, 1.333, pow(sunInfluence, 0.333)), 1.0); // works fine :)
            #elif VOL_LIGHT > 0 && V_CLOUDS < 1
                float fogInfluence = 1.0;
            #elif VOL_LIGHT > 0 && V_CLOUDS > 0
                float fogInfluence = dayBF(mix(1.0, 1.11, fastpow(sunInfluence, 6.0)), 1.0, 1.0);
            #else
                float fogInfluence = dayBF(mix(1.0, 1.11, fastpow(sunInfluence, 6.0)), 1.0, 1.0);
            #endif
        #else
            float fogInfluence = 1.0;
        #endif


        #if FOG_TINT == 0
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), 0.5), vec3(1.0), fog_adj);
        #elif FOG_TINT == 1
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), 1.0), vec3(1.0), fog_adj);
        #elif FOG_TINT == 2
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), -0.5), vec3(1.0), fog_adj);
        #endif

        fogColorMod = saturate(fogColorMod, mix(1.0, 0.0, rainStrength));

        #if MC_VERSION >= 11900
            vec3 fog_texture;
            if(darknessFactor > .01) {
                fog_texture = vec3(0.0);
            } else {
                fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb * fogInfluence * fogColorMod;
            }
        #else
            vec3 fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb * fogInfluence * fogColorMod;
        #endif
        #if defined GBUFFER_ENTITIES
            if(isEyeInWater == 0 && entityId != 10101 && FOG_ADJUST < 15.0) {  // In the air
                block_color.rgb = mix(block_color.rgb, fog_texture, fog_adj);
            }
        #else
            if(isEyeInWater == 0) {  // In the air
                block_color.rgb = mix(block_color.rgb, fog_texture, fog_adj);
            }
        #endif
    #endif
#endif

#if MC_VERSION >= 11900
    if(blindness > .01 || darknessFactor > .01) {
        block_color.rgb = mix(block_color.rgb, vec3(0.0), max(blindness, darknessLightFactor) * gl_FogFragCoord * 0.0);
    }
#else
    if(blindness > .01) {
        block_color.rgb = mix(block_color.rgb, vec3(0.0), blindness * gl_FogFragCoord * 0.2);
    }
#endif
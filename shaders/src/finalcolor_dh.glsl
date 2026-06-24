#if defined DH_WATER
    #ifdef FOG_ACTIVE
        if(isEyeInWater == 0) {
            vec3 fog_texture = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb;
            block_color.rgb = mix(block_color.rgb, fog_texture, fog_adj);
        }
    #endif
#elif defined NETHER
    #if NETHER_FOG_DISTANCE == 1
        block_color.rgb = mix(fogColor * 0.1, vec3(1.0), 0.04);
    #else
        #ifdef FOG_ACTIVE
            block_color.rgb = mix(block_color.rgb, mix(fogColor * 0.5, vec3(1.0), -0.025), fog_adj);
        #endif
    #endif
#elif defined THE_END
    #ifdef FOG_ACTIVE
        block_color.rgb = mix(block_color.rgb, texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb * 1.1 * vec3(1.2, 1.3, 1.2), fog_adj);
    #endif
#else
    #ifdef FOG_ACTIVE
        #if FOG_TINT == 0
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), 0.5), vec3(1.0), fog_adj);
        #elif FOG_TINT == 1
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), 1.0), vec3(1.0), fog_adj);
        #elif FOG_TINT == 2
            vec3 fogColorMod = mix(saturate(vec3(0.592, 0.888, 1.233), -0.5), vec3(1.0), fog_adj);
        #endif

        fogColorMod = saturate(fogColorMod, mix(1.0, 0.0, rainStrength));
        
        vec3 fog_texture = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0.0).rgb * fogColorMod;
        block_color.rgb = mix(block_color.rgb, fog_texture, fog_adj);
    #endif
#endif
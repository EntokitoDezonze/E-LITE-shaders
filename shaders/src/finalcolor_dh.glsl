#ifdef FOG_ACTIVE
    float fogmix = pow(fog_adj, 10);
#endif

#if defined DH_WATER
    #ifdef FOG_ACTIVE
        if(isEyeInWater == 0) {
            vec3 fogColorMod = dayBlend(vec3(0.1529, 0.1725, 0.2), vec3(0.32, 0.48, 0.8) * (1.5 + fog_adj), vec3(0.0275, 0.0392, 0.0549));

            #if FOG_TINT == 0
                fogColorMod = saturate(fogColorMod, 0.5);
            #elif FOG_TINT == 1
                fogColorMod = saturate(fogColorMod, 1.0);
            #elif FOG_TINT == 2
                fogColorMod = saturate(fogColorMod, -0.5);
            #endif

            fogColorMod = mix(fogColorMod, saturate(fogColorMod * vec3(0.8, 0.975, 1.0) * dayBF(0.8, 0.5, 0.6), 0.5), rainStrength);
            
            vec3 fog_texture = mix(fogColorMod, texture2D(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY)).rgb, fogmix);
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
        block_color.rgb = mix(block_color.rgb, texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY), 0.0).rgb * 1.1 * vec3(1.2, 1.3, 1.2), fog_adj);
    #endif
#else
    #ifdef FOG_ACTIVE
        vec3 fogColorMod = dayBlgcy(vec3(0.1529, 0.1725, 0.2), vec3(0.32, 0.48, 0.8) * (1 + fog_adj), vec3(0.0235, 0.0314, 0.0431));

        #if FOG_TINT == 0
            fogColorMod = saturate(fogColorMod, 0.5);
        #elif FOG_TINT == 1
            fogColorMod = saturate(fogColorMod, 1.0);
        #elif FOG_TINT == 2
            fogColorMod = saturate(fogColorMod, -0.5);
        #endif

        fogColorMod = mix(fogColorMod, saturate(fogColorMod * vec3(0.8, 0.975, 1.0) * dayBF(0.8, 0.5, 0.6), 0.5), rainStrength);
        
        vec3 fog_texture = mix(fogColorMod, texture2D(gaux4, gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY)).rgb, fogmix);
        block_color.rgb = mix(block_color.rgb, fog_texture, fog_adj);
    #endif
#endif
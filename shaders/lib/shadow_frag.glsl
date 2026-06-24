vec3 getShadow(vec3 the_shadow_pos, float dither) {
    float shadow_sample = 1.0;

    #if SHADOW_TYPE == 0 || SHADOW_LOCK != 0 // Pixelated
        shadow_sample = shadow2D(shadowtex1, the_shadow_pos).r;
    #elif SHADOW_TYPE > 0 && SHADOW_LOCK == 0 // Soft
        float current_radius = dither;
        float dither_angle = dither * 6.283185307179586;
        
        vec2 offset = (vec2(cos(dither_angle), sin(dither_angle)) * current_radius * SHADOW_BLUR) / shadowMapResolution * 0.85;
        float z_bias = dither_angle * 0.00002;

        float sample1 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
        float sample2 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;

        shadow_sample = (sample1 + sample2) * 0.5;
    #endif

    #if SHADOW_TYPE == 2
        shadow_sample = step(0.5, shadow_sample);
    #endif

    return vec3(shadow_sample);
}

vec3 getShadowAL(vec3 the_shadow_pos, float dither, vec3 flat_normal) {
    float shadow_sample = 1.0;

    #if SHADOW_TYPE == 0 || SHADOW_LOCK != 0 // Pixelated
        shadow_sample = shadow2D(shadowtex1, vec3(the_shadow_pos.xy, the_shadow_pos.z)).r;
    #elif SHADOW_TYPE > 0 && SHADOW_LOCK == 0 // Soft       
        float current_radius = dither;
        float dither_angle = dither * 6.283185307179586;
        
        vec2 offset = (vec2(cos(dither_angle), sin(dither_angle)) * current_radius * SHADOW_BLUR) / shadowMapResolution * 0.85;
        
        float normal_bias = mix(0.0, -0.00005, step(0.0, dot(flat_normal, sunPosition * 0.01)));
        float z_bias = normal_bias + dither_angle * 0.00002;

        float sample1 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
        float sample2 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;

        shadow_sample = (sample1 + sample2) * 0.5;
    #endif

    #if SHADOW_TYPE == 2
        shadow_sample = step(0.5, shadow_sample);
    #endif

    return vec3(shadow_sample);
}
#if defined COLORED_SHADOW

vec3 getColoredShadow(vec3 the_shadow_pos, float dither) {
    #if SHADOW_TYPE == 0 || SHADOW_LOCK != 0 // Pixelated
        float shadow_detector = shadow2D(shadowtex0, the_shadow_pos).r;
        float shadow_black = shadow2D(shadowtex1, the_shadow_pos).r;
        
        vec3 final_color = vec3(1.0);
        float is_colored = step(0.001, abs(shadow_black - shadow_detector));
        
        vec4 colored_tex = texture2D(shadowcolor0, the_shadow_pos.xy);
        float alpha_complement = 1.0 - colored_tex.a;
        vec3 c_rgb = mix(colored_tex.rgb, vec3(1.0), alpha_complement) * alpha_complement;
        
        final_color = mix(vec3(1.0), c_rgb, is_colored);
        final_color = mix(final_color, vec3(0.0), 1.0 - shadow_black);
        final_color = saturate(final_color, 6.0);
        
        return clamp(final_color * (1.0 - shadow_detector) + shadow_detector, vec3(0.0), vec3(1.0));

    #elif SHADOW_TYPE > 0 && SHADOW_LOCK == 0 // Soft / Upscaled
        float current_radius = dither;
        float dither_angle = dither * 6.283185307179586;
        
        vec2 offset = (vec2(cos(dither_angle), sin(dither_angle)) * current_radius * SHADOW_BLUR) / shadowMapResolution;
        float z_bias = dither_angle * 0.00002;

        #if SHADOW_LOCK > 0
            offset *= 0.333;
        #endif

        // Sample 1
        float detector1 = shadow2D(shadowtex0, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
        float black1 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
        vec4 color1 = texture2D(shadowcolor0, the_shadow_pos.xy + offset);

        // Sample 2
        float detector2 = shadow2D(shadowtex0, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;
        float black2 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;
        vec4 color2 = texture2D(shadowcolor0, the_shadow_pos.xy - offset);

        #if SHADOW_TYPE == 2
            detector1 = step(0.5, detector1);
            black1 = step(0.5, black1);
            detector2 = step(0.5, detector2);
            black2 = step(0.5, black2);
        #endif

        float is_colored1 = step(0.001, abs(black1 - detector1));
        float alpha_complement1 = 1.0 - color1.a;
        vec3 processed_color1 = mix(vec3(1.0), mix(color1.rgb, vec3(1.0), alpha_complement1) * alpha_complement1, is_colored1);
        processed_color1 = mix(processed_color1, vec3(0.0), 1.0 - black1);

        float is_colored2 = step(0.001, abs(black2 - detector2));
        float alpha_complement2 = 1.0 - color2.a;
        vec3 processed_color2 = mix(vec3(1.0), mix(color2.rgb, vec3(1.0), alpha_complement2) * alpha_complement2, is_colored2);
        processed_color2 = mix(processed_color2, vec3(0.0), 1.0 - black2);

        vec3 final_color = (processed_color1 + processed_color2) * 0.5;
        final_color = saturate(final_color, 6.0);
        

        float final_detector = (detector1 + detector2) * 0.5;

        #if SHADOW_TYPE == 2
            final_detector = step(0.5, final_detector);
        #endif
        
        return clamp(mix(final_color, vec3(1.0), final_detector), vec3(0.0), vec3(1.0));
    #endif
    }

vec3 getColoredShadowAL(vec3 the_shadow_pos, float dither, vec3 flat_normal) {
    #if SHADOW_TYPE == 0 || SHADOW_LOCK != 0 // Pixelated
        float shadow_detector = shadow2D(shadowtex0, the_shadow_pos).r;
        float shadow_black = shadow2D(shadowtex1, the_shadow_pos).r;
        
        vec3 final_color = vec3(1.0);
        float is_colored = step(0.001, abs(shadow_black - shadow_detector));
        
        vec4 colored_tex = texture2D(shadowcolor0, the_shadow_pos.xy);
        float alpha_complement = 1.0 - colored_tex.a;
        vec3 c_rgb = mix(colored_tex.rgb, vec3(1.0), alpha_complement) * alpha_complement;
        
        final_color = mix(vec3(1.0), c_rgb, is_colored);
        final_color = mix(final_color, vec3(0.0), 1.0 - shadow_black);
        final_color = saturate(final_color, 6.0);
        
        return clamp(final_color * (1.0 - shadow_detector) + shadow_detector, vec3(0.0), vec3(1.0));

    #elif SHADOW_TYPE > 0 && SHADOW_LOCK == 0 // Soft / Upscaled        
        float current_radius = dither;
        float dither_angle = dither * 6.283185307179586;
        
        vec2 offset = (vec2(cos(dither_angle), sin(dither_angle)) * current_radius * SHADOW_BLUR) / shadowMapResolution;
        float normal_bias = mix(0.0, -0.00005, step(0.0, dot(flat_normal, sunPosition * 0.01)));
        float z_bias = normal_bias + dither_angle * 0.00002;

        #if SHADOW_LOCK > 0
            offset *= 0.333;
        #endif

        // Sample 1
        float detector1 = shadow2D(shadowtex0, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
        float black1 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
        vec4 color1 = texture2D(shadowcolor0, the_shadow_pos.xy + offset);

        // Sample 2
        float detector2 = shadow2D(shadowtex0, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;
        float black2 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;
        vec4 color2 = texture2D(shadowcolor0, the_shadow_pos.xy - offset);

        #if SHADOW_TYPE == 2
            detector1 = step(0.5, detector1);
            black1 = step(0.5, black1);
            detector2 = step(0.5, detector2);
            black2 = step(0.5, black2);
        #endif

        float is_colored1 = step(0.001, abs(black1 - detector1));
        float alpha_complement1 = 1.0 - color1.a;
        vec3 processed_color1 = mix(vec3(1.0), mix(color1.rgb, vec3(1.0), alpha_complement1) * alpha_complement1, is_colored1);
        processed_color1 = mix(processed_color1, vec3(0.0), 1.0 - black1);

        float is_colored2 = step(0.001, abs(black2 - detector2));
        float alpha_complement2 = 1.0 - color2.a;
        vec3 processed_color2 = mix(vec3(1.0), mix(color2.rgb, vec3(1.0), alpha_complement2) * alpha_complement2, is_colored2);
        processed_color2 = mix(processed_color2, vec3(0.0), 1.0 - black2);

        vec3 final_color = (processed_color1 + processed_color2) * 0.5;
        final_color = saturate(final_color, 6.0);
        

        float final_detector = (detector1 + detector2) * 0.5;

        #if SHADOW_TYPE == 2
            final_detector = step(0.5, final_detector);
        #endif
        
        return clamp(mix(final_color, vec3(1.0), final_detector), vec3(0.0), vec3(1.0));
    #endif
    }
#endif
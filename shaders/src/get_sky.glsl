/* ____    __    ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - get_sky.glsl
Sky render. - Renderização do céu.
*/

vec3 sky_color;

#if AA_TYPE > 0
    float dither = shifted_semiblue(gl_FragCoord.xy);
#else
    float dither = dither13(gl_FragCoord.xy);
#endif

dither = (dither - .5) * 0.03125;

#if ((COLOR_SCHEME == 2 && SIMPLE_SKY == 0) || COLOR_SCHEME == 5) && !defined UNKNOWN_DIM // LITE Realistic Plus            
    vec4 fragpos = gbufferProjectionInverse * (vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y) / RENDER_SCALE, gl_FragCoord.z, 1.0) * 2.0 - 1.0);
    vec3 nfragpos = normalize(fragpos.xyz);
    float n_u = clamp(dot(nfragpos, up_vec) + 0.1 + dither, 0.0, 1.0);

    float raw_blend = pow(n_u, 0.5); // Sky height
    float blend_initial = mix(0.0, 1.0, raw_blend);

    float transition1_start = 0.0; // Horizon start
    float transition_mid_point = 0.6; // Mid sky max
    float transition2_end = 1.0; // Mid sky end

    // - COLOR INTERPOLATIONS - //
    
    #include "/src/current_sky_color.glsl"
    current_low_sky_color = xyzToRgb(current_low_sky_color);
    current_mid_sky_color = xyzToRgb(current_mid_sky_color);
    current_hi_sky_color = xyzToRgb(current_hi_sky_color);

    float t1 = smoothstep(transition_mid_point, transition2_end, blend_initial + (final_sun_factor * dayBF(0.0, 0.0, 0.1)));
    float t2 = smoothstep(transition1_start, transition_mid_point, blend_initial - dayBF(0.05, 0.1, 0.05) - (final_sun_factor * dayBF(0.05, 0.05, 0.0)));

    vec3 temp_sky_color = mix(current_mid_sky_color * biome_sky, current_hi_sky_color * biome_sky, t1);
    sky_color = mix(current_low_sky_color * biome_sky_low, temp_sky_color, t2);
    sky_color += dither * 3.0 * luma(sky_color);
#elif COLOR_SCHEME == 4 // Vanilla
    vec4 fragpos =
        gbufferProjectionInverse *
        (vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y) / RENDER_SCALE, gl_FragCoord.z, 1.0) * 2.0 - 1.0);
    vec3 nfragpos = normalize(fragpos.xyz);
    float n_u = clamp(dot(nfragpos, up_vec) - 0.1 + dither, 0.0, 1.0);
    
    float raw_blend = pow(n_u, 0.22); // Sky height
    float blend_initial = mix(0.0, 1.0, raw_blend);

    float transition1_start = 0.0; // Horizon start
    float transition_mid_point = 0.65; // Mid sky max
    float transition2_end = 1.0; // Mid sky end

    // - COLOR INTERPOLATIONS - //
    
    #include "/src/current_sky_color.glsl"
    current_low_sky_color = xyzToRgb(current_low_sky_color);
    current_hi_sky_color = xyzToRgb(current_hi_sky_color);

    float t2 = smoothstep(transition1_start, transition_mid_point, blend_initial - 0.2 - (final_sun_factor * dayBF(0.05, 0.05, 0.05)));

    sky_color = mix(current_low_sky_color, current_hi_sky_color, t2);
#else // Using legacy color interpolation.
    vec4 fragpos =
        gbufferProjectionInverse *
        (vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y) / RENDER_SCALE, gl_FragCoord.z, 1.0) * 2.0 - 1.0);
    vec3 nfragpos = normalize(fragpos.xyz);
    float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
    
    #if COLOR_SCHEME == 6
        sky_color = mix(low_sky_color, hi_sky_color, smoothstep(0.0, 1.0, pow(n_u, 0.25)));
    #else
        sky_color = mix(low_sky_color, hi_sky_color, smoothstep(0.0, 1.0, pow(n_u, 0.25)));
    #endif
    sky_color = xyzToRgb(sky_color);
#endif

#ifdef GBUFFER_SKYBASIC
    vec4 background_color = vec4(sky_color, 1.0);
#endif

#ifdef PREPARE_SHADER
    vec3 block_color = sky_color;
#endif
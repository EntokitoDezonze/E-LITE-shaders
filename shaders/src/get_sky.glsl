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
dither = (dither - 0.5) * 0.03125;

#if ((COLOR_SCHEME == 2 && SIMPLE_SKY == 0) || COLOR_SCHEME == 5) && !defined UNKNOWN_DIM 
vec2 screenCoord = gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y) * 2.0 - 1.0;
    vec4 fragpos = gbufferProjectionInverse * vec4(screenCoord, gl_FragCoord.z, 1.0);
    vec3 nfragpos = normalize(fragpos.xyz);
    
    float n_u = clamp(dot(nfragpos, up_vec) + (0.1 + dither), 0.0, 1.0);
    float blend_initial = sqrt(n_u);

    float height_factor = clamp(1.0 - (cameraPosition.y * 0.01587301587), 0.0, 1.0); // 1.0 / 63.0
    height_factor = fastpow(height_factor, 0.1);
    float cave_influence = height_factor * clamp(1.0 - eyeBrightnessSmooth.y * 0.005, 0.0, 1.0);
    cave_influence = smoothstep(0.0, 1.0, cave_influence);
    cave_influence = dayBF(cave_influence, cave_influence, 0.0);

    const float t_mid = 0.6;
    const float t_end = 1.0;

    #include "/src/current_sky_color.glsl"
    
    // CONVERSION
    current_low_sky_color = xyzToRgb(current_low_sky_color);
    current_mid_sky_color = xyzToRgb(current_mid_sky_color);
    current_hi_sky_color = xyzToRgb(current_hi_sky_color);

    float sun_factor_offset = final_sun_factor * dayBF(0.0, 0.0, 0.1);
    float t1 = smoothstep(t_mid, t_end, blend_initial + sun_factor_offset);
    
    float sun_factor_sub = dayBF(0.05, 0.1, 0.05) + (final_sun_factor * dayBF(0.05, 0.05, 0.0));
    float t2 = smoothstep(0.0, t_mid, blend_initial - sun_factor_sub);

    current_mid_sky_color = mix(current_mid_sky_color, saturate(current_mid_sky_color * 0.1, 0.0), cave_influence) * biome_sky;
    current_low_sky_color = mix(current_low_sky_color, saturate(current_low_sky_color * 0.1, 0.0), cave_influence) * biome_sky_low;
    current_hi_sky_color  = mix(current_hi_sky_color,  saturate(current_hi_sky_color * 0.25, 0.5), fastpow(cave_influence, 5.0)) * biome_sky;

    vec3 temp_sky_color = mix(current_mid_sky_color, current_hi_sky_color, t1);
    sky_color = mix(current_low_sky_color, temp_sky_color, t2);
    
    sky_color += dither * (3.0 * luma(sky_color));
#elif COLOR_SCHEME == 4 // Vanilla
    vec2 screenCoord = gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y) / RENDER_SCALE * 2.0 - 1.0;
    vec4 fragpos = gbufferProjectionInverse * vec4(screenCoord, gl_FragCoord.z, 1.0);
    vec3 nfragpos = normalize(fragpos.xyz);
    
    float n_u = clamp(dot(nfragpos, up_vec) - 0.1 + dither, 0.0, 1.0);
    float blend_initial = pow(n_u, 0.22); 

    #include "/src/current_sky_color.glsl"
    current_low_sky_color = xyzToRgb(current_low_sky_color);
    current_hi_sky_color = xyzToRgb(current_hi_sky_color);

    float t2 = smoothstep(0.0, 0.65, blend_initial - 0.2 - (final_sun_factor * dayBF(0.05, 0.05, 0.05)));
    sky_color = mix(current_low_sky_color, current_hi_sky_color, t2);
#else // Legacy
    vec2 screenCoord = gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y) / RENDER_SCALE * 2.0 - 1.0;
    vec4 fragpos = gbufferProjectionInverse * vec4(screenCoord, gl_FragCoord.z, 1.0);
    vec3 nfragpos = normalize(fragpos.xyz);
    
    float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
    float blend = sqrt(sqrt(n_u));
    sky_color = xyzToRgb(mix(low_sky_color, hi_sky_color, smoothstep(0.0, 1.0, blend)));
#endif

#ifdef GBUFFER_SKYBASIC
    vec4 background_color = vec4(sky_color, 1.0);
#endif

#ifdef PREPARE_SHADER
    vec3 block_color = sky_color;
#endif
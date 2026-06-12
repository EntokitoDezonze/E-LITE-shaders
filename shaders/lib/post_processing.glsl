/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - post_processing.glsl #include "/lib/post_processing.glsl"
Utilities, effects and fake effects. - Utilidades, efeitos e efeitos falsos. */

#ifdef VIGNETTE
    float vignette(vec2 uv) {
    vec2 pos = uv - 0.5;
        float dist = length(pos * VIGNETTE_FACTOR);
    return smoothstep(0.8, 0.4, dist);
    }
#endif // Vignette

#ifdef FAKE_BLOOM
    vec3 fakeBloom(vec3 color, float threshold) {
        vec3 bloom = max(color - threshold, 0.0);
        return color + bloom * 0.1 * BLOOM_STRENGTH;
    } // Fake Bloom
#endif

#ifdef FILM_GRAIN
    float noise(vec2 uv) {
        return fract(sin(dot(uv, vec2(12.9898, 78.233))) * mod(frameTimeCounter, 24.0) * 240.0);
    }

    vec3 filmGrain(vec3 color, float grainIntensity, vec2 uv) {
        float grain = noise(uv * 10.0); 
        grain = (grain - 0.5) * 2.0;
        return color + grain * grainIntensity;
    } // Film grain
#endif

#if AA_TYPE == 3
    vec3 sharpen(sampler2D image, vec3 color, vec2 coords) {
        float force = SHARP_FORCE;
        float blur_radius_px = 1.0;

        vec2 offset_x = vec2(blur_radius_px * pixel_size_x, 0.0);
        vec2 offset_y = vec2(0.0, blur_radius_px * pixel_size_y);

        vec3 left_c   = texture2D(image, coords - offset_x).rgb;
        vec3 right_c  = texture2D(image, coords + offset_x).rgb;
        vec3 top_c    = texture2D(image, coords - offset_y).rgb;
        vec3 bottom_c = texture2D(image, coords + offset_y).rgb;

        vec3 min_c = min(color, min(min(left_c, right_c), min(top_c, bottom_c)));
        vec3 max_c = max(color, max(max(left_c, right_c), max(top_c, bottom_c)));

        vec3 blurred_color = (color + left_c + right_c + top_c + bottom_c) * 0.2;
        vec3 high_pass_details = color - blurred_color;
        vec3 sharpened_color = color + high_pass_details * force;

        vec3 clamped_sharpen = clamp(sharpened_color, min_c, max_c);

        float brightness = luma(color);
        float low_mask = smoothstep(0.05, 0.15, brightness);
        float high_mask = smoothstep(0.95, 0.85, brightness);
        float light_mask = low_mask * high_mask;

        return mix(color, clamped_sharpen, light_mask);
    }
#endif
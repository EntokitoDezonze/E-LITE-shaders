/* MakeUp - E-LITE shaders 5 - bloom.glsl
Bloom functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 mipmap_bloom(sampler2D image, vec2 coords, float dither) {
    //if(fragment_cull()) return vec3 (0.0);
    vec3 blur_sample = vec3(0.0);
    vec2 blur_radius_vec = vec2(0.05 * inv_aspect_ratio, 0.05);

    int sample_c = int(clamp(BLOOM_SAMPLES * RENDER_SCALE, 2.0, 10.0));

    vec2 blur_radios_factor = blur_radius_vec * (1.0 / BLOOM_SAMPLES);
    float n;
    vec2 offset;
    float dither_x;

    for(int i = 0; i < sample_c; i++) {
        dither_x = i + dither;
        n = fract(dither_x * 1.6180339887) * 3.141592653589793;
        offset = vec2(cos(n), sin(n)) * dither_x * blur_radios_factor;

        blur_sample += texture2D(image, coords + offset).rgb;
        blur_sample += texture2D(image, coords - offset).rgb;
    }
    
    #if COLOR_SCHEME == 4
        blur_sample /= (BLOOM_SAMPLES * 6.0) / BLOOM_STRENGTH;
    #else
        blur_sample /= (BLOOM_SAMPLES * 3.5) / BLOOM_STRENGTH;
    #endif

    return blur_sample;
}
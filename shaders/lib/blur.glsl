/* MakeUp - E-LITE shaders 5 - blur.glsl
Blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 noised_blur(vec4 color_depth, sampler2D image, vec2 coords, float force, float dither) {
    vec3 block_color = color_depth.rgb;
    float the_depth = color_depth.a;
    float blur_radius = 0.0;

    if (the_depth > 0.56) {  // No hands
        blur_radius =
            max(abs(the_depth - centerDepthSmooth) - 0.000075, 0.0) * fov_y_inv;
        blur_radius = blur_radius * inversesqrt(0.1 + blur_radius * blur_radius) * force;
        blur_radius = min(blur_radius, 0.1);
    }

    if (blur_radius > min(pixelSizeX, pixelSizeY)) {
        vec2 blur_vec = vec2(blur_radius * inv_aspect_ratio, blur_radius);
        vec3 col = vec3(0.0);
        vec3 blur_sum = vec3(0.0);
        float total_weight = 0.0;
        float dither_angle = dither * 6.2831853;
        int samples = 4;

        for(int i = 0; i < samples; i++) {
            float fi = float(i);
            float radius = sqrt((fi + dither) / samples);
            float angle = fi * 2.3999632 + dither_angle;
            float weight = exp(-2.5 * radius * radius);
            
            vec2 offset = vec2(cos(angle), sin(angle)) * blur_vec * radius;
            
            blur_sum += texture2D(image, coords + offset, 0.0).rgb * weight;
            total_weight += weight;
        }

        col = blur_sum / total_weight;

        block_color = col;
    }

    return block_color;
}

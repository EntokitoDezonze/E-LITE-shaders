/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - end_portal.glsl #include "/lib/end_portal.glsl"
End portal render. - Renderização do portal do End. */

#include "/lib/render_aux.glsl"

vec3 end_portal() {
    const int max_layers = 10;
    const float depth_falloff_speed = 4.0;
    const float layer_scale_factor = 20.0;
    const vec2 flow_direction = vec2(0.618034);
    const float flow_speed = 0.2;
    const float noise_base_scale = 5;
    const float color_mix_speed = 0.67;
    const float clip_min = 0.75;
    const float clip_max = 1.0;
    const vec3 base_color = vec3(0.0, 0.0, 0.0);

    const vec3 C0 = vec3(0.498, 0.2353, 0.498);
    const vec3 C1 = vec3(0.1765, 0.2863, 0.7255);
    const vec3 C2 = vec3(0.1608, 0.3961, 0.4941);

    vec2 resolution = vec2(viewWidth, viewHeight);
    float time = mod(frameTimeCounter, 1000.0);

    vec3 world_pos_current = reconstructWorldPosition(gl_FragCoord.z, resolution);

    vec3 final_color = base_color;
    float t_mix = time * color_mix_speed;
    vec3 current_layer_color = mix(C0, C1, sin(t_mix) * 0.5 + 0.5);
    current_layer_color = mix(current_layer_color, C2, cos(t_mix * 0.7) * 0.5 + 0.5);

    vec2 flow_offset = flow_direction * time * flow_speed;
    vec2 base_uv = world_pos_current.xz + cameraPosition.xz;
    base_uv += world_pos_current.y;

    base_uv += flow_offset;
    base_uv += cameraPosition.y * 1.96;

    for (int i = 0; i < max_layers; i++) {
        float layer_factor = float(i) / float(max_layers);
        float inverse_factor = 1.0 - layer_factor;
        
        float scale_factor = noise_base_scale * (1.0 + layer_factor * layer_scale_factor);
        float flow_scale = inverse_factor * 10.0;
        vec2 uv_layer = base_uv * scale_factor;
        uv_layer -= cameraPosition.xz * layer_factor * 50;
        
        uv_layer += flow_offset * flow_scale;

        float noise_val = noise2D_grid(uv_layer);
        float base_intensity = fastpow(noise_val, 5.0);
        float intensity = smoothstep(clip_min, clip_max, base_intensity);

        float layer_fade = pow(inverse_factor, depth_falloff_speed);
        final_color += current_layer_color * intensity * layer_fade * 3.0;

        if (layer_fade < 0.01) break;
    }

    float depth_val = gl_FragCoord.z;
    float overall_depth_fade = 1.0 / (1.0 + depth_val * depth_val * 0.0001);
    final_color *= overall_depth_fade;
    final_color = final_color;

    return final_color;
}
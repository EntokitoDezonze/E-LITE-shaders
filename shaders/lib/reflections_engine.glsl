/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - refelctions_engine.glsl #include "/lib/refelctions_engine.glsl"
Reflections calculation. - Cálculo de reflexos. */

vec3 fast_raymarch(vec3 direction, vec3 hit_coord, inout float infinite, float dither) {
    vec3 dir_increment;
    vec3 current_march = hit_coord;
    vec3 old_current_march;
    float screen_depth;
    float depth_diff = 1.0;
    vec3 march_pos = camera_to_screen(hit_coord);
    float prev_screen_depth = march_pos.z;
    float hit_z = march_pos.z;
    bool search_flag = false;
    bool hidden_flag = false;
    bool first_hidden = true;
    bool out_flag = false;
    bool to_far = false;
    vec3 last_march_pos;
    
    int no_hidden_steps = 0;
    bool hiddens = false;

    // Ray marching
    for (int i = 0; i < RAYMARCH_STEPS; i++) {
        if (search_flag) {
            dir_increment *= 0.5;
            current_march += dir_increment * sign(depth_diff);
        } else {
            old_current_march = current_march;
            current_march = hit_coord + ((direction * exp2(i + dither)) - direction);
            dir_increment = current_march - old_current_march;
        }

        last_march_pos = march_pos;
        march_pos = camera_to_screen(current_march);

        if ( // Is outside screen space
            march_pos.x < 0.0 ||
            march_pos.x > 1.0 ||
            march_pos.y < 0.0 ||
            march_pos.y > 1.0 ||
            march_pos.z < 0.0
        ) {
            out_flag = true;
        }

        if (march_pos.z > 0.9999) {
            to_far = true;
        }

        screen_depth = texture2D(depthtex1, march_pos.xy).x;
        depth_diff = screen_depth - march_pos.z;

        if (depth_diff < 0.0 && abs(screen_depth - prev_screen_depth) > abs(march_pos.z - last_march_pos.z)) {
            hidden_flag = true;
            hiddens = true;
            if (first_hidden) {
                first_hidden = false;
            }
        } else if (depth_diff > 0.0) {
            hidden_flag = false;
            if (!hiddens) {
                no_hidden_steps++;
            }
        }

        if (search_flag == false && depth_diff < 0.0 && hidden_flag == false) {
            search_flag = true;
        }

        prev_screen_depth = screen_depth;
    }

    infinite = float(screen_depth > 0.9999);

    if (out_flag) {
        infinite = 1.0;
        return march_pos;
    } else if (to_far) {
        if (screen_depth > 0.9999) {
            infinite = 1.0;
            return march_pos;
        } else if (no_hidden_steps < 3 || screen_depth > hit_z) {
            return march_pos;
        } else {
            infinite = 1.0;
            return vec3(1.0);
        }
    } else {
        march_pos.xy = clamp(march_pos.xy, vec2(0.0), vec2(RENDER_SCALE));
        return march_pos;
    }
}

vec4 reflection_calc(vec3 reflected, vec3 normal, float roughness) {
    float dither = shifted_eclectic_dither13(gl_FragCoord.xy);
    if (reflected.z >= 0.0) return vec4(0.0);

    vec3 hit_pos;
    float infinite = 0.0;
    vec2 final_uv;

    vec3 rayTarget;
    float distFactor = 25.0;

    #if MATERIAL_GLOSS == 3
        vec3 march_result = fast_raymarch(reflected, sub_position3, infinite, dither);
        rayTarget = sub_position3 + reflected * distFactor;
        vec3 fallback = camera_to_screen(rayTarget);

        float useFallback = float(infinite > 0.5);
        vec2 ssr_uv;

        vec3 view_pos = screen_to_camera(march_result);
        vec3 curr_world_pos = mat3(gbufferModelViewInverse) * view_pos + gbufferModelViewInverse[3].xyz;
        vec3 prev_world_pos = curr_world_pos + (cameraPosition - previousCameraPosition);
        vec3 prev_view_pos = mat3(gbufferPreviousModelView) * prev_world_pos + gbufferPreviousModelView[3].xyz;

        vec2 prev_proj = vec2(
            gbufferPreviousProjection[0].x,
            gbufferPreviousProjection[1].y
        ) * prev_view_pos.xy + gbufferPreviousProjection[3].xy;

        ssr_uv = (prev_proj / -prev_view_pos.z) * 0.5 + 0.5;

        vec2 fallback_uv = fallback.xy;

        final_uv = mix(ssr_uv, fallback_uv, useFallback);
    #else
        rayTarget = sub_position3 + reflected * distFactor;
        vec3 curr_feet_player_pos = mat3(gbufferModelViewInverse) * rayTarget + gbufferModelViewInverse[3].xyz;
        vec3 prev_feet_player_pos = curr_feet_player_pos + (cameraPosition - previousCameraPosition);
        vec3 prev_view_pos = mat3(gbufferPreviousModelView) * prev_feet_player_pos + gbufferPreviousModelView[3].xyz;
        vec2 final_pos_proj = vec2(gbufferPreviousProjection[0].x, gbufferPreviousProjection[1].y) * prev_view_pos.xy + gbufferPreviousProjection[3].xy;
        final_uv = (final_pos_proj / -prev_view_pos.z) * 0.5 + 0.5;
    #endif

    float border_x = max(-fourthPow(abs(2.0 * final_uv.x - 1.0)) + 1.0, 0.0);
    float border_y = max(-fourthPow(abs(2.0 * final_uv.y - 1.0)) + 1.0, 0.0);
    float border = min(border_x, border_y);
    

    #if defined LabPBR && defined GBUFFER_TERRAIN
        float blur_radius = roughness * 0.2;
    #else
        float blur_radius = roughness * 0.05;
    #endif
    
    vec2 blur_vec = vec2(blur_radius * inv_aspect_ratio, blur_radius);
    vec3 col = vec3(0.0);
    
    for(int i = 0; i < 3; i++) {
        float angle = i * 2.0944 + dither * 6.2831;
        vec2 offset = vec2(cos(angle), sin(angle)) * blur_vec * dither;
        col += texture2D(gaux1, final_uv + offset).rgb;
    }
    col /= 3.0;

    return vec4(col, border);
}


vec4 solid_shader(vec3 fragpos, vec3 normal, vec4 color, vec3 sky_reflection, float fresnel, float visible_sky, float roughness, float reflex_index, vec3 f0) {
    float upward = clamp(normal.y, 0.0, 1.0);
    float wetness = rainStrength * upward * visible_sky;

    float currentRoughness = mix(roughness, 0.0, wetness); 
    float smoothness = 1.0 - currentRoughness;
    float currentReflexIndex = mix(reflex_index, 0.0, wetness);

    #if defined LabPBR && defined GBUFFER_TERRAIN
        float isMetal = step(0.9, reflex_index);
        float f_strength = mix(mix(currentReflexIndex, 1.0, fresnel), fresnel, isMetal);
        f_strength *= mix(fastpow(smoothness, 4.0), 1.0, isMetal);
        f_strength = clamp(f_strength, 0.0, (currentReflexIndex + smoothness) * 0.333);
        vec3 tinted_sky = mix(sky_reflection, sky_reflection * f0, isMetal);
    #else
        float f_strength = fresnel * currentReflexIndex;
        vec3 tinted_sky = sky_reflection;
    #endif

    #if defined LabPBR && defined GBUFFER_TERRAIN
        vec3 reflection_color = mix(mix(color.rgb, vec3(0.0), isMetal), tinted_sky, fastpow(visible_sky, 2.0) * f_strength);
    #else
        vec3 reflection_color = mix(color.rgb, tinted_sky, fastpow(visible_sky, 2.0) * f_strength);
    #endif

    #if REFLECTION == 1
        vec4 ssr = reflection_calc(reflect(normalize(fragpos), normal), normal, currentRoughness);
        
        #if defined LabPBR && defined GBUFFER_TERRAIN
            vec3 tinted_ssr = mix(ssr.rgb, ssr.rgb * f0, isMetal);
            reflection_color = mix(reflection_color, tinted_ssr, ssr.a);
        #else
            reflection_color = mix(reflection_color, ssr.rgb, ssr.a);
        #endif
    #endif

    color.rgb = mix(color.rgb, reflection_color, f_strength);

    return color;
}
/* MakeUp - E-LITE shaders 5 - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

/* ---------------*/

vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        vec3 previous = texture2DLod(colortex3, texcoord_past, 0.0).rgb;

        vec3 near_color0 = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, 0.0) * RENDER_SCALE, 0.0).rgb;
        vec3 near_color1 = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, 0.0) * RENDER_SCALE, 0.0).rgb;
        vec3 near_color2 = texture2DLod(colortex1, texcoord + vec2(0.0, -pixelSizeY) * RENDER_SCALE, 0.0).rgb;
        vec3 near_color3 = texture2DLod(colortex1, texcoord + vec2(0.0, pixelSizeY) * RENDER_SCALE, 0.0).rgb;

        // edge detection continua igual, em RGB (não precisa mudar de espaço aqui)
        vec3 edge_color = -near_color0;
        edge_color -= near_color1;
        edge_color += current_color * 4.0;
        edge_color -= near_color2;
        edge_color -= near_color3;

        edge_color = edge_color / (current_color * 2.0);
        float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);
        edge = smoothstep(0.25, 0.75, edge);

        // === clamp de vizinhança agora em YCoCg ===
        vec3 current_ycocg = rgbToYcocg(current_color);
        vec3 previous_ycocg = rgbToYcocg(previous);

        vec3 near0_ycocg = rgbToYcocg(near_color0);
        vec3 near1_ycocg = rgbToYcocg(near_color1);
        vec3 near2_ycocg = rgbToYcocg(near_color2);
        vec3 near3_ycocg = rgbToYcocg(near_color3);

        vec3 nmin =
            min(current_ycocg, min(near0_ycocg, min(near1_ycocg, min(near2_ycocg, near3_ycocg))));
        vec3 nmax =
            max(current_ycocg, max(near0_ycocg, max(near1_ycocg, max(near2_ycocg, near3_ycocg))));

        vec3 center = (nmin + nmax) * 0.5;
        float radio = length(nmax - center);

        vec3 color_vector = previous_ycocg - center;
        float color_dist = length(color_vector);

        float factor = 1.0;
        if (color_dist > radio) {
            factor = radio / color_dist;
        }
        vec3 clamped_ycocg = center + (color_vector * factor);

        previous = ycocgToRgb(clamped_ycocg);

        return mix(current_color, previous, 0.65 + (edge * 0.25));
    }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        vec4 previous = texture2DLod(colortex3, texcoord_past, 0.0);

        vec4 near_color0 = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, 0.0), 0.0);
        vec4 near_color1 = texture2DLod(colortex1, texcoord + vec2(pixelSizeX, 0.0), 0.0);
        vec4 near_color2 = texture2DLod(colortex1, texcoord + vec2(0.0, -pixelSizeY), 0.0);
        vec4 near_color3 = texture2DLod(colortex1, texcoord + vec2(0.0, pixelSizeY), 0.0);

        // edge detection continua igual, em RGB
        vec3 edge_color = -near_color0.rgb;
        edge_color -= near_color1.rgb;
        edge_color += current_color.rgb * 4.0;
        edge_color -= near_color2.rgb;
        edge_color -= near_color3.rgb;

        edge_color = edge_color / (current_color.rgb * 2.0);
        float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);
        edge = smoothstep(0.25, 0.75, edge);

        // === clamp de vizinhança agora em YCoCg ===
        vec3 current_ycocg = rgbToYcocg(current_color.rgb);
        vec3 previous_ycocg = rgbToYcocg(previous.rgb);

        vec3 near0_ycocg = rgbToYcocg(near_color0.rgb);
        vec3 near1_ycocg = rgbToYcocg(near_color1.rgb);
        vec3 near2_ycocg = rgbToYcocg(near_color2.rgb);
        vec3 near3_ycocg = rgbToYcocg(near_color3.rgb);

        vec3 nmin =
            min(current_ycocg, min(near0_ycocg, min(near1_ycocg, min(near2_ycocg, near3_ycocg))));
        vec3 nmax =
            max(current_ycocg, max(near0_ycocg, max(near1_ycocg, max(near2_ycocg, near3_ycocg))));

        vec3 center = (nmin + nmax) * 0.5;
        float radio = length(nmax - center);

        vec3 color_vector = previous_ycocg - center;
        float color_dist = length(color_vector);

        float factor = 1.0;
        if (color_dist > radio) {
            factor = radio / color_dist;
        }
        vec3 clamped_ycocg = center + (color_vector * factor);

        previous = vec4(ycocgToRgb(clamped_ycocg), previous.a);

        return mix(current_color, previous, 0.65 + (edge * 0.25));
    }
}
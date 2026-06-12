/* MakeUp - E-LITE shaders 5 - ao.glsl
Based on old Capt Tatsu's ambient occlusion functions.
*/

float dbao(float dither) {
    float ao = 0.0;

    float inv_steps = 1.0 / clamp(AOSTEPS * RENDER_SCALE, 2.0, 10.0);
    vec2 offset;
    float n;
    float dither_x;

    float d = texture2DLod(depthtex0, texcoord.xy * RENDER_SCALE, 0.0).r;
    float hand_check = d < 0.56 ? 1024.0 : 1.0;
    d = ld(d);

    float sd = 0.0;
    float angle = 0.0;
    float dist = 0.0;
    float far_and_check = hand_check * 2.0 * far;
    vec2 scale = vec2(inv_aspect_ratio, 1.0) * (fov_y_inv / (d * far));
    vec2 scale_factor = scale * inv_steps;
    float sample_d;

    for (int i = 0; i < clamp(AOSTEPS * RENDER_SCALE, 2.0, 10.0); i++) {
        dither_x = (i + dither);
        n = fract(dither_x * 1.6180339887) * 3.141592653589793;
        offset = vec2(cos(n), sin(n)) * dither_x * scale_factor;

        sd = ld(texture2DLod(depthtex0, texcoord.xy * RENDER_SCALE + offset, 0.0).r);
        sample_d = (d - sd) * far_and_check;
        angle = clamp(0.5 - sample_d, 0.0, 1.0);
        dist = clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

        sd = ld(texture2DLod(depthtex0, texcoord.xy * RENDER_SCALE - offset, 0.0).r);
        sample_d = (d - sd) * far_and_check;
        angle += clamp(0.5 - sample_d, 0.0, 1.0);
        dist += clamp(0.25 * sample_d - 1.0, 0.0, 1.0);

        ao += clamp(angle + dist, 0.0, 1.0);
    }
    ao /= AOSTEPS;

    return sqrt((ao * clamp(AO_STRENGTH, 0.0, 1.5)) + (1.0 - clamp(AO_STRENGTH, 0.0, 1.5)));
}

#ifdef DISTANT_HORIZONS
    float dh_dbao(float dither) {
        float ao = 0.0;

        float d_raw = texture2DLod(dhDepthTex0, texcoord.xy, 0.0).r;
        if (d_raw >= 1.0) return 1.0;
        
        float d_lin = ld_dh(d_raw);

        float inv_steps = 1 / AOSTEPS;
        
        vec2 scale = vec2(viewHeight / viewWidth, 1.0) * (1.0 / (d_lin * dhFarPlane * 0.5));
        vec2 scale_factor = scale * inv_steps * AO_STRENGTH * 2.0;

        for (int i = 0; i < AOSTEPS; i++) {
            float dither_x = (float(i) + dither);
            float n = fract(dither_x * 1.6180339887) * 3.1415926535;
            vec2 offset = vec2(cos(n), sin(n)) * dither_x * scale_factor;

            float sd = ld_dh(texture2DLod(dhDepthTex0, texcoord.xy + offset, 0.0).r);
            float diff = (d_lin - sd) * dhFarPlane;
            ao += clamp(0.5 - diff, 0.0, 1.0) + clamp(0.25 * diff - 1.0, 0.0, 1.0);

            sd = ld_dh(texture2DLod(dhDepthTex0, texcoord.xy - offset, 0.0).r);
            diff = (d_lin - sd) * dhFarPlane;
            ao += clamp(0.5 - diff, 0.0, 1.0) + clamp(0.25 * diff - 1.0, 0.0, 1.0);
        }
        
        ao /= AOSTEPS;
        ao = clamp(ao, 0.0, 1.0);

        return sqrt(ao * clamp(AO_STRENGTH, 0.0, 1.3)) + (1.0 - clamp(AO_STRENGTH, 0.0, 1.3));
    }
#endif
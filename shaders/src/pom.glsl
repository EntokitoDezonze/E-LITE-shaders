/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - pom.glsl #include "/src/pom.glsl"
LabPBR: Parallax Occlusion Mapping for normalmapping. - LabPBR: Mapeamento de oclusão por paralaxe para normalmapping. */

vec2 dX = dFdx(texcoord);
vec2 dY = dFdy(texcoord);
vec2 final_uv = texcoord;
float surface_depth = 1.0;

#if defined LabPBR && defined POM && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
    const int steps = POM_STEPS;  
    float pom_fade = clamp((vdist - 16.0) / 16, 0.0, 1.0); 

    if (pom_fade < 1.0 && view_tg.z < 0.0) {
        float delta_max_sqr = max(dot(dX, dX), dot(dY, dY));
        float lod = 0.5 * log2(delta_max_sqr);
        lod = clamp(lod, 0.0, 4.0);

        float noise = shifted_dither13(gl_FragCoord.xy) * 0.5 + 0.5;
        float step_size = 1.0 / float(steps);
        float ray_pos = 1.0 + step_size * noise;

        
        vec2 raw_dir = view_tg.xy * POM_DEPTH * 0.25 / -view_tg.z;
        vec2 uv_step = raw_dir * step_size * (1.0 - pom_fade);
        vec2 p_uv = local_uv + uv_step * noise; 
        
        float lod_factor = clamp(lod / 4.0, 0.0, 1.0);
        for(int i = 0; i < steps * mix(1.0, 0.0, lod_factor); i++) {
            float h_map = texture2DLod(normals, fract(p_uv) * atlas_uv.zw + atlas_uv.xy, lod).a;
            if (ray_pos <= h_map) break;
            p_uv += uv_step;
            ray_pos -= step_size;
        }

        float h_after  = texture2DLod(normals, fract(p_uv) * atlas_uv.zw + atlas_uv.xy, lod).a - ray_pos;
        float h_before = texture2DLod(normals, fract(p_uv - uv_step * 0.1) * atlas_uv.zw + atlas_uv.xy, lod).a - (ray_pos + step_size * 0.1);
        p_uv -= uv_step * 0.1 * clamp(h_after / (h_after - h_before), 0.0, 1.0);

        p_uv = clamp(p_uv, 0.001, 0.999);
        final_uv = fract(p_uv) * atlas_uv.zw + atlas_uv.xy;
        surface_depth = ray_pos;
    }
#endif
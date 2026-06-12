/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - pbr.glsl #include "/lib/pbr.glsl"
LabPBR: Normalmapping and POM shadow functions. - LabPBR: Funções de normalmapping e de sombras POM */

// varying mat3 tbn;

vec3 t = normalize(tbn[0]);
vec3 b = normalize(tbn[1]);
vec3 n = normalize(tbn[2]);

vec3 light_tg = vec3(dot(sunPosition * 0.01, t), dot(sunPosition * 0.01, b), dot(sunPosition * 0.01, n));

vec3 getBumpedNormal(vec2 uv, vec3 flatNormal, sampler2D normalMap) {
    vec4 pbrSample = texture2D(normalMap, uv);
    vec2 pbrXY = pbrSample.rg * 2.0 - 1.0;
    vec3 normalSample = vec3(pbrXY, sqrt(clamp(1.0 - dot(pbrXY, pbrXY), 0.0, 1.0)));

    float invmax = inversesqrt(max(dot(t, t), dot(b, b)));
    return normalize(mat3(t * invmax, b * invmax, flatNormal) * normalSample);
}

vec4 getNormal(vec2 local_p) {
    vec2 clamped_p = clamp(local_p, 0.001, 0.999);
    vec2 final_uv = clamped_p * atlas_uv.zw + atlas_uv.xy;
    
    return texture2D(normals, final_uv);
}

float get_pom_shadow(float surface_h, vec2 p_uv, vec3 light_tg, float dither, vec3 shadow_c) {
    if (light_tg.z <= -0.05 || surface_h > 0.98) return 1.0;
    float step_size = 1.0 / float(SS_SAMPLES), shadow = 1.0;
    vec2 shadow_dir = light_tg.xy * (0.05 / max(light_tg.z, 0.05));

    for(int i = 1; i <= SS_SAMPLES; i++) {
        float factor = float(i) * step_size;
        float ray_h = (surface_h + 0.005) + light_tg.z * factor * POM_DEPTH * 0.025;
        if (ray_h > 1.0 || shadow < 0.01) break;
        float h_map = getNormal(p_uv + shadow_dir * factor * dither).a;
        shadow = min(shadow, 1.0 - clamp((h_map - ray_h) * (24.0 - 12.0 * factor), 0.0, 1.0) * step(ray_h, h_map));
    }
    float luma_inv = 1.0 - luma(direct_light_color);
    float soften = clamp(luma_inv * sqrt(luma_inv) + (0.65 - luma(shadow_c)), 0.0, 1.0);
    
    return mix(shadow * 0.3 + 0.775, 1.0, soften);
}
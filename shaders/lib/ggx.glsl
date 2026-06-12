/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - ggx.glsl #include "/lib/ggx.glsl"
GGX specular gloss. - Brilho especular GGX. */

#if defined THE_END
    vec3 ggxSpecular(vec3 pos, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal, vec3 lightColor, float isMetal) {
        float rough = sqrt(2.0 / (gloss_power + 2.0));
        float a = rough * rough;
        float a2 = a * a;

        vec3 N = normalize(flat_normal);
        vec3 V = normalize(-pos);
        vec3 L = normalize((gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz);
        vec3 H = normalize(V + L);

        float NoH = clamp(dot(N, H), 0.0, 1.0);
        float NoV = clamp(dot(N, V), 0.0, 1.0) + 1e-5;
        float NoL = clamp(dot(N, L), 0.0, 1.0);
        float VoH = clamp(dot(V, H), 0.0, 1.0);

        if (NoL <= 0.0 || NoV <= 0.0) return vec3(0.0);

        float denom = (NoH * NoH) * (a2 - 1.0) + 1.0;
        float D = a2 / (3.14159265 * denom * denom);
        float visInv = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2) + NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
        float G_Over_Denom = 0.5 / max(visInv, 1e-5);

        float f0 = mix(0.04, 0.57, isMetal);
        float F = f0 + (1.0 - f0) * fastpow(1.0 - VoH, 5.0);
        float spec = D * F * G_Over_Denom;
        
        spec = spec / (1.0 + spec);

        return clamp(
            spec * vec3(0.75, 0.75, 1.0) * 10.0, 
            0.0, 1.0
        );
    }
#else
    vec3 ggxSpecular(vec3 pos, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal, vec3 lightColor, float isMetal) {
        float rough = sqrt(2.0 / (gloss_power + 2.0));
        float a = rough* rough;
        float a2 = a * a;

        vec3 N = normalize(flat_normal);
        vec3 V = normalize(-pos);
        vec3 L = mix(-sunPosition, sunPosition, light_mix) * 0.01;
        vec3 H = normalize(V + L);

        float NoH = clamp(dot(N, H), 0.0, 1.0);
        float NoV = clamp(dot(N, V), 0.0, 1.0) + 1e-5;
        float NoL = clamp(dot(N, L), 0.0, 1.0);
        float VoH = clamp(dot(V, H), 0.0, 1.0);

        if (NoL <= 0.01 || NoV <= 0.01) return vec3(0.0);

        float denom = (NoH * NoH) * (a2 - 1.0) + 1.0;
        float D = a2 / (3.14159265 * denom * denom);
        float visInv = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2) + NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
        float G_Over_Denom = 0.5 / max(visInv, 1e-5);

        float f0 = mix(0.04, 0.57, isMetal);
        float F = f0 + (1.0 - f0) * sqrt(1.0 - VoH);
        float spec = D * F * G_Over_Denom;
        
        spec = spec / (1.0 + spec);

        #ifndef LabPBR
            float antiblown = dayBF(dayBF(1.0, 0.0, 1.0), dayBF(0.0, 0.6, 1.0), 1.0);
        #else
            float antiblown = dayBF(dayBF(1.0, 0.0, 1.0), dayBF(0.0, 1.0, 1.0), 1.0);
        #endif
        return clamp(
            spec * saturate(lightColor, dayBF(-0.25, 0.0, 1.0)) * dayBF(1.0, 0.1, 2.5) * antiblown * lmcoord_alt.y * (1.1 - rainStrength), 
            0.0, 1.0
        );
    }
#endif
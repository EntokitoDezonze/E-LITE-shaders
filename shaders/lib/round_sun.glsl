/* ____    __   ______________
  / __/___/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/  
/___/   /____/___/ /_/ /___/  
                                                      
E-LITE shaders 5 - round_sun.glsl
Sun render. - Renderização do sol.
*/

vec3 draw_sun() {
    vec2 resolution = vec2(viewWidth, viewHeight);

    vec3 dir = reconstructWorldPosition(gl_FragCoord.z, resolution); 
    vec3 nDir = normalize(dir);
    vec3 sunDir = normalize(mat3(gbufferModelViewInverse) * sunPosition);
    float cosTheta = dot(nDir, sunDir);

    #if ROUND_SUN == 1
        #if VOL_LIGHT > 0
            float sunSize = 0.001;
            vec3 sunColor = day_blend(vec3(1.0, 0.5, 0.25) * 2.0, vec3(1.0), vec3(1.0, 0.5, 0.5));

            float sunMask = smoothstep(1.0 - sunSize, 1.001 - sunSize, cosTheta);

            float sunY = smoothstep(-0.1, -0.1, sunDir.y);
            float glow = fastpow(max(0.0, cosTheta), 50.0) * 0.5 * sunY;

            return mix((sunColor * 100 * sunMask) + (sunColor * 0.5 * glow), sunColor * glow * 0.3, rainStrength);
        #else
            float sunSize = 0.001;
            vec3 sunColor = day_blend(vec3(1.0, 0.5, 0.25) * 3.0, vec3(2.0), vec3(1.0, 0.5, 0.5));

            float sunMask = smoothstep(1.0 - sunSize, 1.0 - sunSize, cosTheta);

            float sunY = smoothstep(-0.1, 0.1, sunDir.y);
            float glow = fastpow(max(0.0, cosTheta), 63.0) * 0.1 * sunY;

            return mix((sunColor * 100 * sunMask) + (sunColor * glow * 0.6), sunColor * glow * 0.6, rainStrength);
        #endif
    #elif ROUND_SUN == 0
        #if COLOR_SCHEME != 5
            #if VOL_LIGHT > 0
                float glare = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(10.0, 6.0, rainStrength)), 0.0, 1.0); 
                float spot  = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(63.0, 8.0, rainStrength)), 0.0, 1.0);
                spot *= pow(spot, 5.0);

                vec3 sunColor = day_blend_lgcy(vec3(1.0, 0.8, 0.6) * 0.75, vec3(1.0, 0.9, 0.8), vec3(0.0)) * mix(glare * 0.3 + spot * 2.0, glare * day_blend_float(0.1, 0.1, 0.0) + spot * day_blend_float(0.25, 0.15, 0.0), rainStrength);
                return sunColor;
            #else
                float glare = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(10.0, 6.0, rainStrength)), 0.0, 1.0); 
                float spot  = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(63.0, 16.0, rainStrength)), 0.0, 1.0);
                spot *= pow(spot, 5.0);

                vec3 sunColor = day_blend_lgcy(vec3(1.0, 0.8, 0.6) * 0.333, vec3(1.0, 0.9, 0.8), vec3(0.0)) * mix(glare * 0.3 + spot * 1.15, glare * day_blend_float(0.1, 0.1, 0.0) + spot * day_blend_float(0.25, 0.15, 0.0), rainStrength);
                return sunColor;
            #endif
        #else
            vec3 sunColor = vec3(0.0);
            return sunColor;
        #endif
    #endif
}
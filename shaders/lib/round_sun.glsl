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
        float linear = 1.0 - (fastApproxACos(cosTheta) / 1.5708); // arccos(cosTheta) / PI/2
        cosTheta = clamp(linear, 0.0, 1.0);

        #if VOL_LIGHT > 0
            float sunSize = 0.0175;
            vec3 sunColor = dayBlend(vec3(1.0, 0.5, 0.25), vec3(1.0, 0.8, 0.6) * dayBF(0.0, 1.0, 0.0), vec3(1.0, 0.5, 0.5) * 0.1);

            float sunMask = smoothstep(1.0 - sunSize, 1.01 - sunSize, cosTheta);

            float sunY = smoothstep(-0.1, -0.1, sunDir.y);
            float glow = fastpow(max(0.0, cosTheta), 12.0) * 0.5 * sunY;

            return saturate(mix((sunColor * 50 * sunMask) + (sunColor * glow * dayBF(1.5, 2.0, 1.0)), sunColor * glow * 0.3, rainStrength), 1.0 - rainStrength * 0.75);
        #else
            float sunSize = 0.0175;
            vec3 sunColor = dayBlend(vec3(1.0, 0.333, 0.1) * 2.0, vec3(1.0, 0.8, 0.5) * dayBF(0.25, 1.4, 0.0), vec3(1.0, 0.5, 0.5) * 0.1);

            float sunMask = smoothstep(1.0 - sunSize, 1.01 - sunSize, cosTheta);

            float sunY = smoothstep(-0.1, -0.1, sunDir.y);
            float glow = fastpow(max(0.0, cosTheta), 12.0) * 0.5 * sunY;

            return saturate(mix((sunColor * 100 * sunMask) + (sunColor * glow * dayBF(1.0, 1.5, 1.0)), sunColor * glow * 0.6, rainStrength), 1.0 - rainStrength * 0.75);
        #endif
    #elif ROUND_SUN == 0
        #if COLOR_SCHEME != 5
            #if VOL_LIGHT > 0
                float glare = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(10.0, 4.0, rainStrength)), 0.0, 1.0);
                float spot  = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(63.0, 6.0, rainStrength)), 0.0, 1.0);
                spot *= pow(spot, 5.0);

                vec3 sunColor = dayBlgcy(vec3(1.0, 0.8, 0.6) * 0.75, vec3(1.0, 0.8, 0.5), vec3(0.0)) * mix(glare * 0.3 + spot * 2.25, glare * dayBF(0.1, 0.1, 0.0) + spot * dayBF(0.075, 0.05, 0.0), rainStrength);
                sunColor = mix(sunColor, saturate(sunColor, dayBF(0.5, 0.0, 0.0)), rainStrength);
                return sunColor;
            #else
                float glare = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(10.0, 6.0, rainStrength)), 0.0, 1.0); 
                float spot  = clamp(pow(clamp(cosTheta, 0.0, 1.0), mix(63.0, 16.0, rainStrength)), 0.0, 1.0);
                spot *= pow(spot, 5.0);

                vec3 sunColor = dayBlgcy(vec3(1.0, 0.8, 0.6) * 0.333, vec3(1.0, 0.8, 0.5), vec3(0.0)) * mix(glare * 0.25 + spot * 1.75, glare * dayBF(0.1, 0.1, 0.0) + spot * dayBF(0.25, 0.15, 0.0), rainStrength);
                return sunColor;
            #endif
        #else
            vec3 sunColor = vec3(0.0);
            return sunColor;
        #endif
    #endif
}
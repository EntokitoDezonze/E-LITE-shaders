/* MakeUp - water_voxy.glsl
Water reflection and refraction related functions (voxy).
*/

#if SUN_REFLECTION > 0
    #if !defined NETHER && !defined THE_END
        float sun_reflection(vec3 fragpos, float smoothstep1, vec2 lmcoord) {
            vec3 nfragPos = normalize(fragpos);
            vec3 astro_pos = worldTime > 13200 ? moonPosition : sunPosition;
            vec3 nastroPos = normalize(astro_pos);

            float reflection = 0.0;

            #if  SUN_REFLECTION == 2
                vec3 sunDir = normalize(mat3(vxModelViewInv) * sunPosition);
                vec3 nFragWorld = normalize(mat3(vxModelViewInv) * nfragPos);
                vec3 worldUp = vec3(0.00, 1.0, 0.0);
                vec3 rightBase = normalize(cross(worldUp, sunDir));
                vec3 upBase = cross(sunDir, rightBase);

                float rawX = dot(nFragWorld, rightBase);
                float rawY = dot(nFragWorld, upBase);

                float angleRad = sunPathRotation * 0.01745329;
                float maxSunHeight = cos(abs(angleRad));
                float currentHeight = clamp(sunDir.y, 0.0, maxSunHeight);
                float progressToZenith = currentHeight / maxSunHeight;
                progressToZenith = fastpow(progressToZenith, 2.5);
                float dynamicAngle = angleRad * (1.0 - progressToZenith);

                float s = sin(dynamicAngle);
                float c = cos(dynamicAngle);

                float dotX = rawX * c - rawY * s;
                float dotY = rawX * s + rawY * c;

                float square = max(abs(dotX), abs(dotY));

                float size = 1.071 - smoothstep1;
                float frontal_mask = step(0.0, dot(nFragWorld, sunDir));

                reflection = smoothstep(size + 0.01, size, square) * frontal_mask;
            #else
                float astro_vector = max(dot(nfragPos, nastroPos), 0.0);
                reflection = smoothstep(smoothstep1, 1.0, astro_vector);
            #endif

            return clamp(
                (reflection - 0.165) *
                clamp(lmcoord.y, 0.0, 1.0) *
                (1.0 - rainStrength) * dayBF(10.0, 10.0, 5.0), 0.0, 100.0);
        }
    #endif
#endif

vec3 normal_waves_voxy(vec3 pos) {
    float speed = frameTimeCounter * 0.04;
    vec2 wave_1 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.1) + vec2(speed, speed)).rg;
    wave_1 = wave_1 - .5;
    wave_1 *= 0.66;
    vec2 wave_2 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.03125) - speed).rg;
    wave_2 = wave_2 - .5;
    vec2 wave_3 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.125) + vec2(speed, -speed)).rg;
    wave_3 = wave_3 - .5;
    wave_3 *= 1.2;

    vec2 partial_wave = wave_1 + wave_2 + wave_3;
    vec3 final_wave = vec3(partial_wave, WATER_TURBULENCE - (rainStrength * 0.6 * WATER_TURBULENCE));

    return normalize(final_wave);
}

vec3 refraction_voxy(vec3 fragpos, vec3 color, vec3 refraction) {
    vec2 pos = gl_FragCoord.xy * vec2(pixelSizeX, pixelSizeY);

    #if REFRACTION == 1
        pos = pos + refraction.xy * (0.075 / (1.0 + length(fragpos) * 0.4));
    #endif

    const float vxNear = 16.0;
    const float vxFar  = 48000.0;

    float water_absortion;
    if (isEyeInWater == 0) {
        float water_distance = 2.0 * vxNear * vxFar / (vxFar + vxNear - (2.0 * gl_FragCoord.z - 1.0) * (vxFar - vxNear));
        float earth_distance = texture2D(vxDepthTexTrans, pos.xy).x;
        earth_distance = 2.0 * vxNear * vxFar / (vxFar + vxNear - (2.0 * earth_distance - 1.0) * (vxFar - vxNear)); 
        water_absortion = max(earth_distance - water_distance, 0.0);
        water_absortion = (1.0 / -((water_absortion * WATER_ABSORPTION) + 1.33)) + 1.0;
        water_absortion = clamp(water_absortion, 0.0, 1.0);
    } else {
        water_absortion = 0.0;
    }

    return mix(texture(gaux1, pos.xy).rgb * mix(vec3(0.9, 1.0, 1.0), vec3(0.8, 1.3, 1.6) * 0.9, water_absortion), color, water_absortion);
}

vec3 get_normals_voxy(vec3 bump, vec3 fragpos, vec3 tangent, vec3 binormal, vec3 waterNormal) {
    float NdotE = abs(dot(waterNormal, normalize(fragpos)));

    bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);

    mat3 tbn_matrix = mat3(
        tangent.x, binormal.x, waterNormal.x,
        tangent.y, binormal.y, waterNormal.y,
        tangent.z, binormal.z, waterNormal.z
    );

    return normalize(bump * tbn_matrix);
}

vec4 reflection_calc_voxy(vec3 fragpos, vec3 normal) {
    vec3 reflected = reflect(normalize(fragpos), normal);
    vec3 pos = camera_to_screen_voxy(fragpos + reflected * 768.0);

    float border =
        clamp((1.0 - (max(0.0, abs(pos.y - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

    border = clamp(border - pow(pos.y, 10.0), 0.0, 1.0);

    pos.x = abs(pos.x);
    if (pos.x > 1.0) {
        pos.x = 1.0 - (pos.x - 1.0);
    }

    return vec4(texture(gaux1, pos.xy).rgb, border);
}

vec3 water_shader_voxy(
    vec3 fragpos,
    vec3 normal,
    vec3 color,
    vec3 sky_reflect,
    float fresnel,
    float visibleSky,
    vec3 lightColor,
    vec2 lmcoord
) {
    vec4 reflection = vec4(0.0);
    float infinite = 1.0;

    #if REFLECTION == 1
        reflection =
            reflection_calc_voxy(fragpos, normal);
    #endif

    reflection.rgb = mix(
        sky_reflect * visibleSky,
        reflection.rgb,
        reflection.a
    );

    #ifdef VANILLA_WATER
        fresnel *= 0.8;
    #endif

    #if SUN_REFLECTION > 0
        #ifndef NETHER
            #ifndef THE_END
                return mix(color, reflection.rgb, fresnel * REFLEX_INDEX) +
                    vec3(sun_reflection(reflect(normalize(fragpos), normal), 0.999, lmcoord)) * lightColor * infinite * visibleSky;
            #else
                return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
            #endif
        #else
            return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
        #endif
    #else
        return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
    #endif
}

vec4 cristal_reflection_calc_voxy(vec3 fragpos, vec3 normal) {
    vec3 reflectedVector = reflect(normalize(fragpos), normal) * 768.0;
    vec3 pos = camera_to_screen_voxy(fragpos + reflectedVector);

    float border_x = max(-fourthPow(abs(2.0 * pos.x - 1.0)) + 1.0, 0.0);
    float border_y = max(-fourthPow(abs(2.0 * pos.y - 1.0)) + 1.0, 0.0);
    float border = min(border_x, border_y);

    return vec4(texture(gaux1, pos.xy, 0.0).rgb, border);
}

vec4 cristal_shader_voxy(
    vec3 fragpos,
    vec3 normal,
    vec4 color,
    vec3 skyReflectionColor,
    float fresnel,
    float visibleSky,
    vec3 lightColor,
    vec2 lmcoord
) {
    vec4 reflection = vec4(0.0);
    float infinite = 0.0;

    #if REFLECTION == 1
        reflection = cristal_reflection_calc_voxy(fragpos, normal);
    #endif

    skyReflectionColor = mix(color.rgb, skyReflectionColor, visibleSky * visibleSky);

    reflection.rgb = mix(
        skyReflectionColor,
        reflection.rgb,
        reflection.a
    );

    color.rgb = mix(color.rgb, skyReflectionColor, fresnel);
    color.rgb = mix(color.rgb, reflection.rgb, fresnel);

    color.a = mix(color.a, 1.0, fresnel * .9);

    #if SUN_REFLECTION == 1
        #ifndef NETHER
        #ifndef THE_END
            return color + vec4(
                mix(
                    vec3(sun_reflection(reflect(normalize(fragpos), normal), 0.99, lmcoord) * lightColor * infinite * visibleSky),
                    vec3(0.0),
                    reflection.a
                ),
                0.0
            );
        #else
            return color;
        #endif
        #else
            return color;
        #endif
    #else
        return color;
    #endif
}

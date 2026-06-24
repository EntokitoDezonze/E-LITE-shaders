float isTintable = step(0.01, gl_Color.g - gl_Color.r + 0.001) + step(0.01, gl_Color.g - gl_Color.b + 0.001);

#if defined GBUFFER_TERRAIN
    tint_color = mix(gl_Color, gl_Color * seasonColor, clamp(isTintable, 0.0, 1.0));
#else
    tint_color = gl_Color;
#endif

visible_sky = clamp(lmcoord.y * 1.0695 - 0.0695, 0.0, 1.0);

if (isEyeInWater == 1) {
    visible_sky = (visible_sky * 0.95) + 0.05;
}

#if defined UNKNOWN_DIM
    visible_sky = (visible_sky * 0.99) + 0.01;
#endif

float ix = lmcoord.x;
float l_pow = 1.17;
#if defined GBUFFER_ENTITIES
    l_pow = 0.9;
#endif

float ix2 = ix * ix * l_pow;
float ix4 = ix2 * ix2;
float ix8 = ix4 * ix4;
float ix15 = ix8 * ix4 * ix2 * ix;

#if COLOR_SCHEME == 5
    candle_color = CANDLE_BASELIGHT * (ix + ix8);
#else
    candle_color = CANDLE_BASELIGHT * (ix2 * ix15 + ix * sqrt(ix));
    if(ix2 * ix15 + ix * sqrt(ix) > 4.0) candle_color = gray(CANDLE_BASELIGHT * 2.0);
#endif

#ifdef DYN_HAND_LIGHT
    if (heldItemId == 11001 || heldItemId2 == 11001 || heldItemId == 11002 || heldItemId2 == 11002) {
        float h_off = (heldItemId == 11001 || heldItemId2 == 11001) ? 0.0 : 0.333;
        float h_off2 = (heldItemId == 11002 || heldItemId2 == 11002) ? 0.0 : 0.166;
        float h_dist = clamp(1.0 - (gl_FogFragCoord * 0.0666 + h_off + h_off2), 0.0, 1.0);

        float hd2 = h_dist * h_dist * l_pow;
        float hd4 = hd2 * hd2;
        float hd8 = hd4 * hd4;
        candle_color = max(candle_color, CANDLE_BASELIGHT * (h_dist * hd2 + (hd8 * hd4 * hd2 * h_dist)));
    }
#endif

#if defined GBUFFER_HAND
    candle_color *= 0.333 * vec3(0.9, 0.95, 1.0);
#endif

candle_color = clamp(candle_color, 0.0, 4.0);

#if defined THE_END || defined NETHER
    vec3 sun_vec = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 sun_vec = sunPosition * 0.01;
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float sun_light_strength;
// --- OPTIMIZATION #2: Avoid length() in condicional ---
if (dot(normal, normal) > 0.0001) { // Workaround for undefined normals
    normal = normalize(normal);
    float ndotl = dot(normal, sun_vec);
    sun_light_strength = clamp((ndotl + dayBF(0.2, 0.2, 0.0) * step(0.01, ndotl)), -1.0, 1.0);   
} else {
    normal = vec3(0.0, 1.0, 0.0);
    sun_light_strength = 1.0;
}

vec3 sunWorldVec = normalize(mat3(gbufferModelViewInverse) * sun_vec);
float ydotl = clamp(sunWorldVec.y, 0.0, 1.0);

vec3 normalWorld = mat3(gbufferModelViewInverse) * normal;
vec3 outNormal = normalize(normalWorld);

#if defined THE_END || defined NETHER
    direct_light_strength = sun_light_strength;
#else
    direct_light_strength = mix(-sun_light_strength, sun_light_strength, light_mix);
#endif

#ifdef UNKNOWN_DIM
    direct_light_color = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb * dayBlgcy(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR * 1.5);
#else
    direct_light_color = dayBlgcy(
        LIGHT_SUNSET_COLOR * dayBF(1.0, 1.4, 0.0),  
        LIGHT_DAY_COLOR * dayBF(1.25, 1.0, 1.0) * mix(1.5 - ydotl, 1.0, rainStrength),
        LIGHT_NIGHT_COLOR * dayBF(0.0, 1.0, 1.25));
    
    #if COLOR_SCHEME == 4
        direct_light_color *= dayBF(2.0, 1.25, 2.0);
    #endif
    
    #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
        direct_light_color += (endFlashIntensity * endFlashIntensity * 0.05);
    #endif
#endif

#ifdef FOLIAGE_V
    float is_fol = step(0.2, isFoliage);

    float foliage_light = mix(direct_light_strength * 0.75, 1.0, 1.0 * (rainStrength * 0.5 + 0.5));

    direct_light_strength = mix(mix(clamp(direct_light_strength, 0.0, 1.0), foliage_light, is_fol), clamp(direct_light_strength, 0.0, 1.0), float(isEyeInWater));
#else
    direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
#endif

float omni_strength = (direct_light_strength * 0.25) + 1.0;
float vs2 = visible_sky * visible_sky;
float vs4 = vs2 * vs2;

float dayBlendSunset = dayBF(dayBF(1.0, 1.0, 4.0), 1.0, 1.0);

#if !defined THE_END && !defined NETHER
    float rain_mul = dayBF(0.4, 0.3, 1.0);
    #if COLOR_SCHEME == 4
        rain_mul = dayBF(0.5, 0.4, 0.4);
    #endif
    
    direct_light_color = mix(direct_light_color, ZENITH_SKY_RAIN_COLOR * luma(direct_light_color) * rain_mul, rainStrength);

    float isUpside = 1.0 - smoothstep(0.51, 0.75, outNormal.y);
    #if COLOR_SCHEME == 2 || COLOR_SCHEME == 6
        #ifndef SHADOW_CASTING
            outNormal.y = outNormal.y * 0.5 + 0.5;
        #endif
        #ifdef FOLIAGE_V
            if(is_fol > 0.99) outNormal.y = 1.0;
        #endif
        vec3 omni_color = saturate(mix(hi_sky_color_rgb * mix(dayBF(3.0, 4.5, 4.0), dayBF(4.0, 6.0, 5.5), rainStrength) * dayBlendSunset * mix(1.0, outNormal.y * 0.4 + 0.6, visible_sky * isUpside) * OMNI_MUL, direct_light_color * dayBF(1.0, 0.4, 6.0) * OMNI_MUL, OMNI_TINT), 0.28);
    #elif COLOR_SCHEME == 4
        vec3 omni_color = direct_light_color * (OMNI_MUL + dayBF(0.1, 0.1, 0.5));
    #else
        vec3 omni_color = mix(hi_sky_color_rgb, direct_light_color * 0.45, OMNI_TINT) * (OMNI_MUL + 0.7);
    #endif

    #ifdef SIMPLE_AUTOEXP
        float l_ratio = clamp(AVOID_DARK_LEVEL / (luma(omni_color) * 100.0), 0.25, 10.0);
    #else
        float l_ratio = clamp(AVOID_DARK_LEVEL / (luma(omni_color) * 100.0), 0.0, 10.0);
    #endif
    vec3 omni_min = omni_color * l_ratio;

    #if COLOR_SCHEME != 5
        float mask = clamp((1.0 - visible_sky) + rainStrength + step(49.0, AVOID_DARK_LEVEL), 0.0, 1.0);
        omni_min *= mix(dayBF(7.5, 15.0, 3.75) * OMNI_MUL, 1.0, mask); // Fullbright rework
    #endif
        
    omni_min *= dayBF(1.0, 1.0, 0.25 + 0.75 * (step(49.0, AVOID_DARK_LEVEL))); // Fullbright rework

    #if COLOR_SCHEME != 5
        omni_color = clamp(omni_color, AVOID_DARK_LEVEL * 0.01, 10.0);
    #else
        omni_color = clamp(omni_color, AVOID_DARK_LEVEL * 0.0025, 10.0);
    #endif    
    
    #ifdef SIMPLE_AUTOEXP
        omni_min = mix(omni_min / max(luma(omni_min), 0.001) * 0.15 + 0.05 * step(49.0, AVOID_DARK_LEVEL), omni_min, visible_sky);
    #else
        omni_min = mix(omni_min / max(luma(omni_min), 0.001) * 0.0333 + 0.2 * step(49.0, AVOID_DARK_LEVEL), omni_min, visible_sky);
    #endif

    omni_light = mix(omni_min, omni_color, vs4) * omni_strength;

#else
    #ifdef THE_END
        omni_light = LIGHT_DAY_COLOR * 2.0;
    #else
        omni_light = vec3(0.05 + 0.2 * step(49.0, AVOID_DARK_LEVEL));
    #endif
#endif

// Thanks to tas for reporting bug that made caves a bit too bright, this code is from LITE 4.7.3.
#if !defined THE_END && !defined NETHER
    #ifdef SHADOW_CASTING
        direct_light_strength *= visible_sky;
    #else
        direct_light_strength *= mix(visible_sky, vs2 * visible_sky, float(isEyeInWater == 0));
    #endif
#endif
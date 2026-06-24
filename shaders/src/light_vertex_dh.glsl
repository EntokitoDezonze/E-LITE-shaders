tint_color = gl_Color;

#if defined THE_END || defined NETHER
    vec2 illumination = vec2(lmcoord.x, 1.0);
#else
    vec2 illumination = lmcoord;
#endif

illumination.y = clamp(illumination.y * 1.0695 - 0.0695, 0.0, 1.0);
visible_sky = illumination.y;

visible_sky = mix(visible_sky, (visible_sky * 0.95) + 0.05, float(isEyeInWater == 1));

#if defined UNKNOWN_DIM
    visible_sky = (visible_sky * 0.99) + 0.01;
#endif

float ix = illumination.x;
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
    candle_color = CANDLE_BASELIGHT * (ix2 + ix15 + ix * sqrt(ix));
#endif

candle_color = clamp(candle_color, 0.0, 4.0);

#if defined THE_END || defined NETHER
    vec3 sun_vec = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 sun_vec = sunPosition * 0.01;
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float sun_light_strength;

float normal_sq = dot(normal, normal);
if (normal_sq > 0.0001) {
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
        LIGHT_DAY_COLOR * dayBF(1.25, 1.25, 1.0) * mix(1.5 - ydotl, 1.0, rainStrength), 
        LIGHT_NIGHT_COLOR * dayBF(0.0, 1.0, 1.25));
    
    #if COLOR_SCHEME == 4
        direct_light_color *= dayBF(2.0, 1.25, 2.0);
    #endif
    
    #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
        direct_light_color += (endFlashIntensity * endFlashIntensity * 0.05);
    #endif
#endif

direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);

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
        omni_min *= mix(dayBF(7.5, 15.0, 3.75) * OMNI_MUL, 1.0, mask);
    #endif
    
    omni_min *= dayBF(1.0, 1.0, 0.25 + 0.75 * (step(49.0, AVOID_DARK_LEVEL)));

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

    #ifdef SIMPLE_AUTOEXP
        omni_light = mix(omni_min, omni_color, vs4) * omni_strength;
    #else
        omni_light = mix(omni_min, omni_color, vs4) * omni_strength;
    #endif

#else
    #ifdef THE_END
        omni_light = LIGHT_DAY_COLOR * 2.0;
    #else
        omni_light = vec3(0.05 + 0.2 * step(49.0, AVOID_DARK_LEVEL));
    #endif
#endif

#if !defined THE_END && !defined NETHER
    float shadow_fac = mix(vs4 * vs4 * vs4, visible_sky, float(min(isEyeInWater, 1.0)));
    #ifdef SHADOW_CASTING
        direct_light_strength = mix(direct_light_strength * 0.5, direct_light_strength, shadow_fac);
    #else
        direct_light_strength = mix(0.0, direct_light_strength, shadow_fac);
    #endif
#endif

direct_light_strength = mix(direct_light_strength, 10.0, float(dhMaterialId == DH_BLOCK_ILLUMINATED));
direct_light_strength = mix(direct_light_strength, 1.0, float(dhMaterialId == DH_BLOCK_LAVA));
direct_light_strength = mix(direct_light_strength, sqrt(direct_light_strength + 0.1), float(dhMaterialId == DH_BLOCK_LEAVES));
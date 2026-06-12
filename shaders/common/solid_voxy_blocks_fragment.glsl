#include "/lib/config.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"
#include "/lib/dither.glsl"

/* Color utils */

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

#if defined MATERIAL_GLOSS && !defined NETHER
    #include "/lib/material_gloss_fragment_voxy.glsl"
#endif

layout(location = 0) out vec4 gbufferData0;
layout(location = 1) out vec4 gbufferData1;

/*
struct VoxyFragmentParameters {
	vec4 sampledColour;
	vec2 tile;
	vec2 uv;
	uint face;
	uint modelId;
	vec2 lightMap;
	vec4 tinting;
	uint customId;
};
*/

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    // Includes

    #include "/src/voxy_uniforms_replace.glsl"
    #include "/src/hi_sky_voxy.glsl"

    // Banderas especiales

    bool isFoliageEntity = (
        customId == ENTITY_LOWERGRASS ||
        customId == ENTITY_UPPERGRASS ||
        customId == ENTITY_SMALLGRASS ||
        customId == ENTITY_SMALLENTS ||
        customId == ENTITY_LEAVES ||
        customId == ENTITY_SMALLENTS_NW
    );

    #include "/src/voxy_position_light.glsl"

    float farDirectLightStrength = clamp(directLightStrength, 0.0, 1.0);
    if (isFoliageEntity) {  // It's foliage, light is atenuated by angle
        if (customId != ENTITY_LEAVES) {
            farDirectLightStrength = farDirectLightStrength * 0.25 + 0.75;
        }
        if (customId == ENTITY_LEAVES) {
           farDirectLightStrength = directLightStrength * 0.5 + 0.5;
        }

        #ifdef SHADOW_CASTING
            directLightStrength = sqrt(abs(directLightStrength));
        #else
            directLightStrength = (clamp(directLightStrength, 0.0, 1.0) * 0.5 + 0.5) * 0.75;
        #endif
        omniStrength = 1.0;
    } else {
        directLightStrength = clamp(directLightStrength, 0.0, 1.0);
    }

    #if defined THE_END || defined NETHER
        #ifdef THE_END
            vec3 omniLight = LIGHT_DAY_COLOR * 2.0;
        #else
            vec3 omniLight = LIGHT_DAY_COLOR * omniStrength;
        #endif
    #else
        directLightColor = mix(directLightColor, ZENITH_SKY_RAIN_COLOR * luma(directLightColor) * rain_mul, rainStrength);
        float isUpside = 1.0 - smoothstep(0.51, 0.75, normal.y);

        #if COLOR_SCHEME == 2 || COLOR_SCHEME == 6
            #ifndef SHADOW_CASTING
                normal.y = normal.y * 0.5 + 0.5;
            #endif
            vec3 omniColor = saturate(mix(ZenithSkyColorRGB * mix(dayBlendFloatVoxyN(3.0, 4.5, 4.0, dayMixerV, nightMixerV, dayMomentV), dayBlendFloatVoxyN(4.0, 6.0, 5.5, dayMixerV, nightMixerV, dayMomentV), rainStrength) * dayBlendSunset * mix(1.0, normal.y * 0.4 + 0.6, visibleSky * isUpside) * OMNI_MUL, directLightColor * dayBlendFloatVoxyN(1.0, 0.4, 6.0, dayMixerV, nightMixerV, dayMomentV) * OMNI_MUL, OMNI_TINT), 0.28);
        #elif COLOR_SCHEME == 4
            vec3 omniColor = directLightColor * (OMNI_MUL + dayBlendFloatVoxy(0.1, 0.1, 0.5, dayMixerV, nightMixerV, dayMomentV));
        #else
            vec3 omniColor = mix(ZenithSkyColorRGB, directLightColor * 0.45, OMNI_TINT) * (OMNI_MUL + 0.7);
        #endif

        #ifdef SIMPLE_AUTOEXP
            float lumaRatio = clamp(AVOID_DARK_LEVEL / (luma(omniColor) * 100.0), 0.25, 10.0);
        #else
            float lumaRatio = clamp(AVOID_DARK_LEVEL / (luma(omniColor) * 100.0), 0.0, 10.0);
        #endif
        vec3 omniColorMin = omniColor * lumaRatio;

        #if COLOR_SCHEME != 5
            float mask = clamp((1.0 - visibleSky) + rainStrength + step(49.0, AVOID_DARK_LEVEL), 0.0, 1.0);
            omniColorMin *= mix(dayBlendFloatVoxy(7.5, 15.0, 3.75, dayMixerV, nightMixerV, dayMomentV) * OMNI_MUL, 1.0, mask);
        #endif

        omniColorMin *= dayBlendFloatVoxy(1.0, 1.0, 0.25 + 0.75 * (step(49.0, AVOID_DARK_LEVEL)), dayMixerV, nightMixerV, dayMomentV);

        #if COLOR_SCHEME != 5
            omniColor = clamp(omniColor, AVOID_DARK_LEVEL * 0.01, 10.0);
        #else
            omniColor = clamp(omniColor, AVOID_DARK_LEVEL * 0.0025, 10.0);
        #endif

        omniColorMin = mix(omniColorMin / max(luma(omniColorMin), 0.001) * 0.0333, omniColorMin, visibleSky);

        vec3 omniLight = mix(omniColorMin, omniColor, visibleSky * visibleSky * visibleSky * visibleSky) * omniStrength;
    #endif

    #if !defined THE_END && !defined NETHER
        #ifndef SHADOW_CASTING
            if (isEyeInWater == 0) {
                float visSky2 = visibleSky * visibleSky;
                directLightStrength = mix(0.0, directLightStrength, visSky2 * visibleSky);
            } else {
                directLightStrength = mix(0.0, directLightStrength, visibleSky);
            }
        #else
            directLightStrength *= visibleSky;
        #endif
    #endif

    if (customId == ENTITY_EMMISIVE) {
        directLightStrength = 10.0;
    } else if (customId == ENTITY_S_EMMISIVE) {
        directLightStrength = 1.0;
    }

    // Fog Vertex

    // 1. Reconstruir posición en clip space
    vec2 ndc = (gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0 - 1.0;
    float depth = gl_FragCoord.z * 2.0 - 1.0;
    vec4 clipPos = vec4(ndc, depth, 1.0);

    // 2. Pasar a world space
    vec4 worldPos = vxViewProjInv * clipPos;
    worldPos /= worldPos.w;

    // 3. La distancia desde la cámara (equivalente a gl_FogFragCoord)
    float fogFragCoord = length(worldPos.xyz);

    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);

    vec4 viewPosition = vxProjInv * clipPos;
    viewPosition /= viewPosition.w;
    vec3 viewPositionNormalized = normalize(viewPosition.xyz);

    float invFogAdjust = 1.0 / FOG_ADJUST;
    float nearFogVoxy = 0.0;

    #if !defined THE_END && !defined NETHER
        float rainMod = mix(1.0, dayBlendFloatVoxyN(0.525, 0.525, 0.65, dayMixerV, nightMixerV, dayMomentV), rainStrength);
        float fog_density_coeff = dayBlendFloatVoxy(
            FOG_SUNSET * rainMod,
            FOG_DAY,
            FOG_NIGHT * rainMod,
            dayMixerV,
            nightMixerV,
            dayMomentV
        ) * FOG_ADJUST;

        #ifdef FOG_ACTIVE
            vec3 dirToSun = sunPosition * 0.01;
            float sunAngle = smoothstep(-0.8, 1.0, dot(dirToSun, viewPositionNormalized));
            float sunInfluenceV = sunAngle * sunAngle * sunAngle;
        #endif

        #if defined NEAR_FOG && defined FOG_ACTIVE
            float sunDayFactor = dayBlendFloatVoxyN(1.0, 0.1, 0.0, dayMixerV, nightMixerV, dayMomentV);
            float dynamic_density = 0.003 + (0.001 * sunInfluenceV * sunDayFactor);

            float dist_adj = max(0.0, fogFragCoord - (float(vxRenderDistance * 16) / mix(24.0, 240.0, rainStrength)));
            nearFogVoxy = clamp(1.0 - exp(-dist_adj * dynamic_density * mix(1.0, 2.5, rainStrength) * invFogAdjust), 0.0, 1.0);
        #endif

        float horizonFogVoxy = pow(
            clamp(fogFragCoord / float(vxRenderDistance * 16) / 32, 0.0, 1.0),
            mix(fog_density_coeff, fog_density_coeff * 0.2, rainStrength)
        );

        float frogAdjust = max(nearFogVoxy, horizonFogVoxy);
    #else
        // --- END / NETHER ---
        #if defined NETHER
            float sight = float(vxRenderDistance * 16);
            float density = 0.1;
        #else
            float sight = float(vxRenderDistance * 16);
            float density = 0.003;
        #endif

        #ifdef NEAR_FOG
            float dist_adj = max(0.0, fogFragCoord - (sight * 0.1));
            nearFogVoxy = clamp(1.0 - exp(-dist_adj * density * invFogAdjust), 0.0, 1.0);
        #endif

        float horizon_fog = clamp(fogFragCoord / sight, 0.0, 1.0);
        float frogAdjust = max(nearFogVoxy, pow(horizon_fog, FOG_ADJUST * 0.25));
    #endif

    #if !defined NETHER
        #ifdef SHADOW_CASTING
            if (isFoliageEntity) {
                directLightStrength = farDirectLightStrength;  // Shortcut
            }
        #endif
    #endif

    #if defined MATERIAL_GLOSS && !defined NETHER
        float lumaFactor = 1.0;
        float lumaPower = 2.0;
        float glossPower = 6.0;
        float glossFactor = 1.05;

        if(customId == ENTITY_SAND) {  // Sand-like block
            lumaPower = 4.0;
        } else if(customId == ENTITY_METAL) {  // Metal-like block
            lumaFactor = 1.35;
            lumaPower = -1.0;  // Metallic
            glossPower = 100.0;
        } else if(customId == ENTITY_FABRIC) {  // Fabric-like blocks
            glossPower = 3.0;
            glossFactor = 0.1;
        }
    #endif

    // ---- Original Fragment Logic

    #if AA_TYPE > 0
        float dither = shifted_r_dither(gl_FragCoord.xy);
    #else
        float dither = r_dither(gl_FragCoord.xy);
    #endif

    vec4 blockColor = parameters.sampledColour * tintColor;

    float block_luma = luma(blockColor.rgb);

    vec3 finalCandleColor = candleColor;
    if (customId == ENTITY_EMMISIVE) {
        finalCandleColor *= block_luma * 1.5;
    }

    float shadowValue = abs((dayNightMix * 2.0) - 1.0);

    #if defined MATERIAL_GLOSS && !defined NETHER
        block_luma *= lumaFactor;

        if(lumaPower < 0.0) {  // Metallic
            glossPower -= (block_luma * 73.334);
        } else {
            block_luma = pow(block_luma, lumaPower);
        }

        float material_gloss_factor = materialGloss(reflect(viewPositionNormalized, normal), lmcoord, glossPower, normal) * glossFactor;

        float material = material_gloss_factor * block_luma;
        vec3 realLight = omniLight +
            (shadowValue * ((directLightColor * directLightStrength) + (directLightColor * material))) * (1.0 - (rainStrength * 0.75)) +
            finalCandleColor;
    #else
        vec3 realLight = omniLight +
            (shadowValue * directLightColor * directLightStrength) * (1.0 - (rainStrength * 0.75)) +
            finalCandleColor;
    #endif

    blockColor.rgb *= mix(realLight, vec3(1.0), nightVision * 0.125);
    blockColor.rgb *= mix(vec3(1.0, 1.0, 1.0), vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B), nightVision);

    blockColor = clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));

    #include "/src/finalcolor_voxy.glsl"

    if (blindness > .01) {
        blockColor.rgb = vec3(0.0);
    }

    // Real color
    gbufferData0 = blockColor;
    gbufferData1 = blockColor;
}
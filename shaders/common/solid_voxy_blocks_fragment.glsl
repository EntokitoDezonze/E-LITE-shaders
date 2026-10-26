#include "/lib/config.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/luma.glsl"
#include "/lib/dither.glsl"

// == Color utils
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
        if (customId != ENTITY_LEAVES && customId != ENTITY_SMALLGRASS) {
            farDirectLightStrength = farDirectLightStrength;
        } else if (customId == ENTITY_SMALLGRASS) {
            farDirectLightStrength = directLightStrength * 0.25 + 0.75;
        } else if (customId == ENTITY_LEAVES) {
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

    #include "/src/light_vertex_vx.glsl"

    // Fog Vertex

    // 1. Reconstruir posición en clip space
    vec2 ndc = (gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0 - 1.0;
    float depth = gl_FragCoord.z * 2.0 - 1.0;
    vec4 clipPos = vec4(ndc, depth, 1.0);

    // 2. Pasar a world space
    vec4 worldPos = vxViewProjInv * clipPos;
    worldPos /= worldPos.w;

    vec4 fragposition = vxProjInv * clipPos;
    fragposition /= fragposition.w;

    #include "/src/fog_voxy.glsl"

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
    blockColor.rgb = saturate(blockColor.rgb, mix(1.0, 0.8, rainStrength));

    float block_luma = luma(blockColor.rgb);

    vec3 finalCandleColor = candleColor;
    if (customId > 6999.5 && customId < 7017.5) {
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
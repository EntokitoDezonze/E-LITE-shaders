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

#include "/lib/projection_utils_voxy.glsl"
#include "/lib/water_voxy.glsl"

layout(location = 0) out vec4 gbufferData0;

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
    #include "/src/low_sky_voxy.glsl"

    vec3 mid_sky_color;
    #include "/src/mid_sky_voxy.glsl"

    #include "/src/voxy_position_light.glsl"

    float farDirectLightStrength = clamp(directLightStrength, 0.0, 1.0);
    directLightStrength = clamp(directLightStrength, 0.0, 1.0);

    #include "/src/light_vertex_vx.glsl"

    vec3 binormal = normalize(vxModelView[2].xyz);
    vec3 tangent = normalize(vxModelView[0].xyz);
    vec3 upVector = normalize(vxModelView[1].xyz);

    // Fog Vertex

    // 1. Reconstruir clip space (base común)
    vec2 ndc = (gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0 - 1.0;
    float depth = gl_FragCoord.z * 2.0 - 1.0;
    vec4 clipPos = vec4(ndc, depth, 1.0);

    // 2. View space
    vec4 viewSpacePos4D = vxProjInv * clipPos;
    viewSpacePos4D /= viewSpacePos4D.w;
    vec3 fragposition = viewSpacePos4D.xyz;

    // 3. World space derivado directamente de fragposition
    vec4 worldPos = vxModelViewInv * viewSpacePos4D;
    vec4 worldposition = worldPos + vec4(cameraPosition, 0.0);

    #include "/src/fog_voxy.glsl"

    #include "/src/current_sky_color_voxy.glsl"
    // ---- Original Fragment Logic

    vec4 blockColor;
    vec3 realLight;

    #ifdef VANILLA_WATER
        vec3 waterNormalBase = vec3(0.0, 0.0, 1.0);
    #else
        vec3 waterNormalBase = normal_waves_voxy(worldposition.xzy);
    #endif

    vec3 surfaceNormal;
    if(customId == ENTITY_WATER) {  // Water
        surfaceNormal = get_normals_voxy(waterNormalBase, fragposition, tangent, binormal, normal);
    } else {
        surfaceNormal = get_normals_voxy(vec3(0.0, 0.0, 1.0), fragposition, tangent, binormal, normal);
    }

    float normalDotEye = dot(surfaceNormal, normalize(fragposition));
    float fresnel = squarePow(1.0 + normalDotEye);

    vec3 reflectWaterVector = reflect(fragposition, surfaceNormal);
    vec3 normalizedReflectWaterVector = normalize(reflectWaterVector);

    vec3 hi_sky_color = zenithSkyColor;
    vec3 skyColorReflect;
    float lumaModulator = dayBlendFloatVoxyN(1.0, 1.0, dayBlendFloatVoxyN(0.6, 1.0, 1.0, dayMixerV, nightMixerV, dayMomentV), dayMixerV, nightMixerV, dayMomentV);

    if(isEyeInWater == 0 || isEyeInWater == 2) {
        skyColorReflect = mix(current_low_sky_color * lumaModulator, zenithSkyColor * lumaModulator * lumaModulator, sqrt(clamp(dot(normalizedReflectWaterVector, upVector), 0.0001, 1.0)));
    } else {
        skyColorReflect = zenithSkyColor * .5 * ((eyeBrightSmoothFloat.y * .8 + 48) * 0.004166666666666667);
    }

    skyColorReflect = oklabToRgb(skyColorReflect);

    if(customId == ENTITY_WATER) {  // Water
        #ifdef VANILLA_WATER
            blockColor = parameters.sampledColour;

            float shadowValue = abs((dayNightMix * 2.0) - 1.0);
            float fresnelTex = luma(blockColor.rgb);

            realLight = omniLight +
                (directLightStrength * shadowValue * directLightColor) * (1.0 - rainStrength * 0.75) +
                candleColor;

            realLight *= 1.25;
            realLight *= (fresnelTex * 2.0) - 0.25;

            blockColor.rgb *= mix(realLight, vec3(1.0), nightVision * .125) * tintColor.rgb;

            blockColor.rgb = water_shader_voxy(fragposition, surfaceNormal, blockColor.rgb, skyColorReflect, fresnel, visibleSky, directLightColor, lmcoord);

            blockColor.a = sqrt(blockColor.a);
        #else
            #if WATER_TEXTURE == 1
                blockColor = parameters.sampledColour;
                float waterTexture = luma(blockColor.rgb);
            #else
                float waterTexture = 1.0;
            #endif

            float water_texture = waterTexture;

            realLight = omniLight +
                (directLightStrength * visibleSky * directLightColor) * (1.0 - rainStrength * 0.75) +
                candleColor;

            #if WATER_COLOR_SOURCE == 0
                blockColor.rgb = waterTexture * realLight * WATER_COLOR;
            #elif WATER_COLOR_SOURCE == 1
                blockColor.rgb = 0.3 * waterTexture * realLight * tintColor.rgb;
            #endif

            blockColor = vec4(refraction_voxy(fragposition, blockColor.rgb, waterNormalBase), 1.0);

            #if WATER_TEXTURE == 1
                float water_texture2 = waterTexture + 0.25;
                water_texture2 *= water_texture2;
                fresnel = clamp(fresnel * (water_texture2), 0.0, 1.0);
                float normalfactor = sqrt(waterTexture * 0.5 + 0.5) / 0.9;
            #else
                float normalfactor = 1.0;
            #endif

            blockColor.rgb = water_shader_voxy(fragposition, surfaceNormal * normalfactor, blockColor.rgb, skyColorReflect, fresnel, visibleSky, directLightColor, lmcoord);
        #endif
    } else {  // Otros translúcidos
        blockColor = parameters.sampledColour;

        blockColor *= tintColor;

        float shadowValue = abs((dayNightMix * 2.0) - 1.0);

        realLight = omniLight +
            (directLightStrength * shadowValue * directLightColor) * (1.0 - rainStrength * 0.75) +
            candleColor;

        blockColor.rgb *= mix(realLight, vec3(1.0), nightVision * .125);

        if(customId == ENTITY_STAINED) {  // Glass
            blockColor = cristal_shader_voxy(fragposition, normal, blockColor, skyColorReflect, fresnel * fresnel, visibleSky, directLightColor, lmcoord);
        }
    }

    #include "/src/finalcolor_voxy.glsl"

    if (blindness > .01) {
        blockColor.rgb = vec3(0.0);
    }

    gbufferData0 = blockColor;
}
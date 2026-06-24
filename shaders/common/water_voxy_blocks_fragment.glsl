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

    #if defined THE_END || defined NETHER
        #ifdef THE_END
            vec3 omniLight = LIGHT_DAY_COLOR * 2.0;
        #else
            vec3 omniLight = vec3(0.05 + 0.2 * step(49.0, AVOID_DARK_LEVEL));
        #endif
    #else
        directLightColor = mix(directLightColor, ZENITH_SKY_RAIN_COLOR * luma(directLightColor) * rain_mul, rainStrength);
        float isUpside = 1.0 - smoothstep(0.51, 0.75, normal.y);

        #if COLOR_SCHEME == 2 || COLOR_SCHEME == 6
            #ifndef SHADOW_CASTING
                normal.y = normal.y * 0.5 + 0.5;
            #endif
            vec3 omniColor = saturate(mix(ZenithSkyColorRGB * mix(dayBlendFloatVoxyN(3.0, 4.5, 4.0, dayMixerV, nightMixerV, dayMomentV), dayBlendFloatVoxyN(4.0, 6.0, 5.5, dayMixerV, nightMixerV, dayMomentV), rainStrength) * dayBlendSunset * mix(1.0, normal.y * 0.4 + 0.6, visibleSky * isUpside) * OMNI_MUL, directLightColor * dayBlendFloatVoxy(1.0, 0.4, 6.0, dayMixerV, nightMixerV, dayMomentV) * OMNI_MUL, OMNI_TINT), 0.28);
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

        #ifdef SIMPLE_AUTOEXP
            omniColorMin = mix(omniColorMin / max(luma(omniColorMin), 0.001) * 0.15 + 0.05 * step(49.0, AVOID_DARK_LEVEL), omniColorMin, visibleSky);
        #else
            omniColorMin = mix(omniColorMin / max(luma(omniColorMin), 0.001) * 0.0333 + 0.2 * step(49.0, AVOID_DARK_LEVEL), omniColorMin, visibleSky);
        #endif

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

    // 3. La distancia desde la cámara (equivalente a gl_FogFragCoord)
    float fogFragCoord = length(worldPos.xyz);

    vec2 eyeBrightSmoothFloat = vec2(eyeBrightnessSmooth);
    vec3 viewPositionNormalized = normalize(fragposition);

    float invFogAdjust = 1.0 / FOG_ADJUST;
    float nearFogVoxy = 0.0;

    #if !defined THE_END && !defined NETHER
        float rainMod = mix(1.0, 1.5, rainStrength);
        float fog_density_coeff = dayBlendFloatVoxy(
            FOG_SUNSET,
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
            float dynamic_density = 0.002 + (0.001 * sunInfluenceV * sunDayFactor);

            float dist_adj = max(0.0, fogFragCoord - (float(vxRenderDistance * 16) / mix(24.0, 240.0, rainStrength)));
            nearFogVoxy = clamp(1.0 - exp(-dist_adj * dynamic_density * mix(1.0, 2.5, rainStrength) * invFogAdjust), 0.0, 1.0);
        #endif

        float horizonFogVoxy = pow(
            clamp(fogFragCoord / float(vxRenderDistance * 16), 0.0, 1.0),
            mix(fog_density_coeff, fog_density_coeff * 0.2, rainStrength)
        );

        float frogAdjust = max(nearFogVoxy, horizonFogVoxy);
    #else
        // --- END / NETHER ---
        #if defined NETHER
            float sight = float(vxRenderDistance * 16);
        #else
            float sight = float(vxRenderDistance * 16) * 0.75;
        #endif

        float horizon_fog = pow(clamp(fogFragCoord / sight, 0.0, 1.0), 0.75);
        float frogAdjust = max(nearFogVoxy, pow(horizon_fog, FOG_ADJUST * 0.25));
    #endif

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

    vec3 skyColorReflect;
    if(isEyeInWater == 0 || isEyeInWater == 2) {
        skyColorReflect = mix(current_low_sky_color, current_hi_sky_color, sqrt(clamp(dot(normalizedReflectWaterVector, upVector), 0.0001, 1.0)));
    } else {
        skyColorReflect = zenithSkyColor * .5 * ((eyeBrightSmoothFloat.y * .8 + 48) * 0.004166666666666667);
    }

    skyColorReflect = xyzToRgb(skyColorReflect);

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

            //realLight *= mix(mix(0.666, 1.0, fresnel), 1.0, WATER_ABSORPTION * 10 - 0.5);

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
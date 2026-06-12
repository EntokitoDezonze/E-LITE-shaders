/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/  
/___/   /____/___/ /_/ /___/
                                    
E-LITE shaders - solid_blocks_fragment.glsl
Render of almost all blocks & PBR. */

#include "/lib/config.glsl"

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

uniform sampler2D tex, specular, normals, gaux1, gaux3, gaux4, shadowcolor0, depthtex1;
uniform sampler2DShadow shadowtex1, shadowtex0;

uniform float viewWidth, viewHeight, far, near, light_mix, rainStrength, wetness, blindness, frameTime, frameTimeCounter, inv_aspect_ratio, nightVision, dhNearPlane;
uniform float pixel_size_x, pixel_size_y; // pixel_size
uniform int frameCounter, isEyeInWater, worldTime, entityId;
uniform vec3 sunPosition, moonPosition, cameraPosition, previousCameraPosition;
uniform vec4 entityColor;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjection, gbufferProjectionInverse, gbufferModelView, gbufferPreviousModelView, gbufferModelViewInverse, gbufferPreviousProjection, shadowModelView, shadowProjection;

#if MC_VERSION >= 11900
    uniform float darknessFactor, darknessLightFactor;
#endif

/* Packing */
varying vec4 data_pack_a; // x: fog_adj, y: direct_light_strength, z: block_type_f, w: exposure
varying vec4 data_pack_b; // x: near_fog, y: visible_sky, z: sunInfluence, w: roughness
varying vec2 emissiveData; // x: ore_type_f, y: emitter_type_f
varying vec3 foliageData; // x: isFoliage, y: isSeasonable, z: isGrass

varying vec2 texcoord;
varying vec4 tint_color;
varying vec3 direct_light_color, candle_color, omni_light;

#if defined LabPBR && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
    varying vec4 vDistTg;
    float vdist = vDistTg.a;
    vec3 view_tg = vDistTg.rgb;
    varying vec4 atlas_uv;
    varying vec2 local_uv;
    varying mat3 tbn;
#endif

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1 || defined LabPBR
    varying vec3 sub_position3, sub_position3_norm;
    varying vec2 lmcoord_alt;
    varying vec4 glossParms;
    varying float reflexIndex;
#endif

varying vec3 flat_normal;

#if defined SHADOW_CASTING && !defined NETHER
    varying vec4 shadowParms;
    vec3 shadow_pos = shadowParms.rgb;
    float shadow_diffuse = shadowParms.a;
    #if SHADOW_LOCK > 0
        varying vec3 vNormal, vBias, vWorldPos;
    #endif
#endif

float fog_adj, direct_light_strength, block_type_f, exposure;
float near_fog, visible_sky, sunInfluence, roughness;
float ore_type_f, emitter_type_f, isGrass;
float reflex_index2;
vec3 final_candle_color;
vec4 pure_block_color; 
vec2 pixel_size;

#include "/lib/luma.glsl"
#include "/lib/depth.glsl"
#include "/lib/basic_utils.glsl"
#include "/lib/projection_utils.glsl"

#if defined LabPBR && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
    #include "/lib/pbr.glsl"
#endif

#include "/lib/dither.glsl"

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_frag.glsl"
#endif

#if MATERIAL_GLOSS > 0 && !defined NETHER
    #include "/lib/ggx.glsl"
#endif

#if MATERIAL_GLOSS > 1 && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
    #include "/lib/reflections_engine.glsl"
#endif

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

#include "/lib/end_portal.glsl"
vec3 computeRealLight(vec3 omni, vec3 directColor, float directStrength, vec3 shadow, vec3 material, vec3 candle) {
    return (omni + shadow * directColor * (directStrength * (1.0 + material)) * (1.0 - (rainStrength * 0.75))) + candle;
}
varying float vanilla_ao;
void main() {
    /* Unpack */
    vec3 viewPos = mat3(gbufferProjectionInverse) * (vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z) * 2.0 - 1.0);
    vec4 tmp = gbufferProjectionInverse * vec4(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z) * 2.0 - 1.0, 1.0);
    viewPos = tmp.xyz / tmp.w;
    vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    fog_adj = data_pack_a.x;
    direct_light_strength = data_pack_a.y;
    block_type_f = data_pack_a.z;
    exposure = data_pack_a.w;
    near_fog = data_pack_b.x;
    visible_sky = data_pack_b.y;
    sunInfluence = data_pack_b.z;
    roughness = data_pack_b.w;
    isGrass = foliageData.z;

    // === Parallax
    #if defined LabPBR && defined POM && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        #include "/src/pom.glsl"
    #else
        vec2 final_uv = texcoord;
    #endif

    // === Auxiliary
    pure_block_color = texture2D(tex, final_uv);
    vec4 block_color = vec4(pure_block_color.rgb * tint_color.rgb, pure_block_color.a);
    float block_luma = luma(block_color.rgb);
    block_color.rgb *= vanilla_ao;

    pixel_size = vec2(pixel_size_x, pixel_size_y);
    final_candle_color = candle_color;
    
    #if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
        reflex_index2 = reflexIndex;
    #endif
    
    #if (defined SHADOW_CASTING && !defined NETHER) || defined DISTANT_HORIZONS || (MATERIAL_GLOSS > 0 && !defined NETHER) || defined LabPBR
        #if AA_TYPE > 0 
            float dither = shifted_dither13(gl_FragCoord.xy);
        #else
            float dither = r_dither(gl_FragCoord.xy);
        #endif
    #endif

    #if defined DISTANT_HORIZONS && !defined GBUFFER_BEACONBEAM
        float t = far - dhNearPlane;
        float umbral = (gl_FogFragCoord - (dhNearPlane + (t * TRANSITION_DH_INF))) / (far - (t * TRANSITION_DH_SUP) - (t * TRANSITION_DH_INF) - dhNearPlane);
        if(umbral > dither) { discard; return; }
    #endif

    // === Block detection
    int ore_type = int(round(emissiveData.x));
    int emitter_type = int(round(emissiveData.y));
    int block_type = int(round(block_type_f));
    
    // === End portal render
    #ifdef END_PORTAL
        float endLuma = 1.0;
        if (block_type == 1){ block_color.rgb = end_portal();
        endLuma = 1.0 - luma(block_color.rgb);
        reflex_index2 = 1.0 * endLuma; roughness = 5.0 * endLuma;}
    #endif

    if (block_type == 2){reflex_index2 = 0.5; roughness = 5.0;}

    // === Shadows calc
    #if defined SHADOW_CASTING && !defined NETHER
        #if SHADOW_LOCK > 0
            vec3 offsetVector = vNormal * 0.002;
            vec3 preSnapPos = vWorldPos + offsetVector;
            float texelSize = SHADOW_LOCK;
            vec3 absPos = preSnapPos + cameraPosition;
            vec3 snappedAbsolute = floor(absPos * texelSize) / texelSize;
            snappedAbsolute += 0.5 / texelSize; 
            vec3 final_world_pos = (snappedAbsolute - cameraPosition) + vBias;
            vec3 shadow_real_pos = get_shadow_pos(final_world_pos);
        #else
            vec3 shadow_real_pos = shadow_pos;
        #endif

        #if defined COLORED_SHADOW
            vec3 shadow_c = mix(get_colored_shadoww(shadow_real_pos, dither, flat_normal), vec3(1.0), shadow_diffuse);
        #else
            vec3 shadow_c = mix(get_shadoww(shadow_real_pos, dither, flat_normal), vec3(1.0), shadow_diffuse);
        #endif
    #else
        vec3 shadow_c = vec3(abs((light_mix * 2.0) - 1.0));
    #endif

    // === Grass correction
    #ifdef SHADOW_CASTING
        float directLight2;
        if(isEyeInWater == 0) {
            directLight2 = mix(direct_light_strength, (sqrt(sqrt(direct_light_strength) * 0.85) * luma(shadow_c)), float(isGrass > 0.5));
        } else {
            directLight2 = mix(direct_light_strength, (direct_light_strength * 0.5 * luma(shadow_c)), float(isGrass > 0.5));  
        }
    #else
        float directLight2 = direct_light_strength;
    #endif

    // === PBR auxiliary
    #if defined LabPBR && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        vec3 bumpedNormal;
        if(block_type != 1.0) {
            bumpedNormal = getBumpedNormal(texcoord, flat_normal, normals);
        } else {
            bumpedNormal = flat_normal;
        }
    #else
        vec3 bumpedNormal = flat_normal;
    #endif

    #if !defined NETHER && defined LabPBR && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        vec3 shadowLightDir = mix(-sunPosition, sunPosition, light_mix) * 0.01;
        float diffuseRelief = clamp(dot(bumpedNormal, shadowLightDir), 0.0, 1.0);
        float shadow_c_relief = (isGrass < 0.5) ? sqrt(directLight2 * diffuseRelief) : directLight2;
    #else
        float shadow_c_relief = directLight2;
    #endif
    
    #if defined LabPBR && defined POM && defined POM_SHADOW && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        float shadow_factor = 1.0;
        if (pom_fade < 1.0) {
            shadow_factor = get_pom_shadow(surface_depth, local_uv, light_tg, dither, shadow_c);
        }
        block_color.rgb *= shadow_factor;
    #endif
    
    // === Block reflection
    float currentRoughness = roughness;
    #if (MATERIAL_GLOSS > 0 && !defined NETHER)
        #if defined LabPBR && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
            vec4 specMap = texture2D(specular, final_uv);
            float smoothness = specMap.r;
            float f0_val = mix(specMap.g * (1.0 - specMap.a), specMap.g, step(1.0, specMap.a));
            float isMetal = step(0.9, f0_val);
            float final_gloss_power = pow(smoothness, 4.0) * 256.0 + 1.0;
            float block_luma2 = block_luma + smoothness * mix(30.0, 100.0, isMetal);
            block_luma2 *= pow(smoothness, 4.0);
            currentRoughness = pow(1.0 - smoothness, 2.0);
        #else
            float final_gloss_power = glossParms.g;
            float block_luma2 = pow(block_luma * glossParms.b, glossParms.a);
            float isMetal = 0.0;
        #endif

        vec3 gloss = ggxSpecular(sub_position3, lmcoord_alt, final_gloss_power, bumpedNormal, direct_light_color * glossParms.r, isMetal);
        gloss = clamp(gloss, 0.0, 1.0);
        block_color.rgb = saturate(block_color.rgb, max(1.0 - luma(gloss * 2), 0.75));
        vec3 real_light = computeRealLight(omni_light, direct_light_color, shadow_c_relief, shadow_c, gloss * block_luma2, candle_color);
    #else
        vec3 gloss = vec3(0.0);
        vec3 real_light = computeRealLight(omni_light, direct_light_color, shadow_c_relief, shadow_c, vec3(0.0), candle_color);
    #endif

    block_color.rgb *= mix(real_light, vec3(1.0), nightVision * 0.125);
    block_color.rgb *= mix(vec3(1.0), vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B), nightVision);

    // === Entity Damage / Thunderbolt
    #if defined GBUFFER_ENTITIES
        if(entityId == 10101) {
            block_color = vec4(1.0, 1.0, 1.0, 0.5);
        } else {
            block_color.rgb = mix(block_color.rgb, entityColor.rgb, entityColor.a * luma(real_light) * 3.0);
        }
    #endif
    
    #include "/lib/emissive_materials.glsl"

    // === SSR
    #if MATERIAL_GLOSS > 1 && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        if ((reflex_index2 + currentRoughness) > 0.001) {
            vec3 R = reflect(sub_position3_norm, bumpedNormal);
            vec2 sky_uv = vec2(atan(R.z, R.x) * 0.1591549 + 0.5, acos(-R.y) * 0.3183098 + 0.1);
            vec3 sky_refl = texture2D(gaux4, clamp(sky_uv, 0.01, 0.99)).rgb;
            block_color = solid_shader(sub_position3, bumpedNormal, block_color, sky_refl, clamp(1.0 + dot(bumpedNormal, sub_position3_norm), 0.0, 1.0), visible_sky, currentRoughness, reflex_index2);
        }
    #endif

    #ifdef DISTANT_HORIZONS
        block_color.rgb *= mix(1.0, 0.5, pow(fog_adj, 2.0));
    #endif
    block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));

    #include "/src/finalcolor.glsl"
    #include "/src/writebuffers.glsl"
}
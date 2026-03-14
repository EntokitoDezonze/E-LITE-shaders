#include "/lib/config.glsl"

// MAIN FUNCTION ------------------

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform float viewWidth;
uniform float inv_aspect_ratio;
uniform float viewHeight;
uniform int frameCounter;
uniform float frameTime;
uniform float far;
uniform sampler2D tex;
uniform int isEyeInWater;
uniform float nightVision;
uniform float rainStrength;
uniform float wetness;
uniform float light_mix;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D gaux4;
uniform vec3 sunPosition;
uniform sampler2D depthtex0;
uniform float near;
uniform ivec2 eyeBrightnessSmooth;
uniform vec4 lightningBoltPosition;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;

#if MATERIAL_GLOSS > 1
    uniform sampler2D gaux1;
    uniform mat4 gbufferPreviousProjection;
    uniform mat4 gbufferPreviousModelView;
    uniform mat4 gbufferProjectionMatrix;
#endif

#if defined GBUFFER_BLOCK || SHADOW_LOCK > 0 && defined SHADOW_CASTING
    uniform float frameTimeCounter;
#endif

#if defined GBUFFER_BLOCK || SHADOW_LOCK > 0 && defined SHADOW_CASTING || (defined MATERIAL_GLOSS && !defined NETHER) || ((MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1)
    uniform vec3 cameraPosition;
    uniform vec3 previousCameraPosition;
    uniform mat4 gbufferModelViewInverse;
#endif

#if defined DISTANT_HORIZONS
    uniform float dhNearPlane;
#endif

#if defined GBUFFER_ENTITIES
    uniform int entityId;
    uniform vec4 entityColor;
#endif

#if defined SHADOW_CASTING
    uniform sampler2DShadow shadowtex1;
    #if defined COLORED_SHADOW
        uniform sampler2DShadow shadowtex0;
        uniform sampler2D shadowcolor0;
    #endif
#endif

uniform float blindness;

#if MC_VERSION >= 11900
    uniform float darknessFactor;
    uniform float darknessLightFactor;
#endif

#ifdef MATERIAL_GLOSS
     // Don't remove
#endif

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
    uniform int worldTime;
    uniform vec3 moonPosition;
    uniform mat4 gbufferModelView;
#endif

#if SHADOW_LOCK > 0 && defined SHADOW_CASTING
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;
varying float fog_adj;
varying float near_fog;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying float exposure;
varying vec3 hi_sky_color;
varying vec3 low_sky_color;
varying float block_type_f;
varying float isSeasonable;
varying float isGrass;


//#if RENDER_SCALE_INT != 100 && defined FSR
 //   varying float depth;
//#endif

#if defined EMISSIVE_MATERIAL || defined EMISSIVE_ORE
    varying float ore_type_f;
    varying float emitter_type_f;
#endif

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    varying vec3 vWorldPos;
    varying vec3 vNormal;
    varying vec3 vBias;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 shadow_pos;
    varying float shadow_diffuse;
#endif

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
    varying float visible_sky;
    varying vec2 lmcoord_alt;
    varying vec4 glossParms;
    varying vec3 sub_position3;
    varying vec3 sub_position3_norm;
    varying vec3 flat_normal;
#endif

#if MATERIAL_GLOSS > 1
    varying float roughness;
    varying float reflexIndex;
#endif

#ifdef FOG_ACTIVE
    varying float sunInfluence;
#endif

/* Utility functions */

#include "/lib/luma.glsl"
#include "/lib/depth.glsl"
#include "/lib/basic_utils.glsl"

#if MATERIAL_GLOSS > 1
    #include "/lib/projection_utils.glsl"
#endif

#if (defined SHADOW_CASTING && !defined NETHER) || defined DISTANT_HORIZONS || ((MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1)
    #include "/lib/dither.glsl"
#endif

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_frag.glsl"
#endif

#if MATERIAL_GLOSS > 0 && !defined NETHER
    #include "/lib/material_gloss_fragment.glsl"
#endif

#if MATERIAL_GLOSS > 1 && (defined GBUFFER_TERRAIN || defined GBUFFER_HAND || defined GBUFFER_BLOCK)
    #include "/lib/reflections_engine.glsl"
#endif

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

#if defined GBUFFER_BLOCK
    #include "/lib/end_portal.glsl"
#endif

#define FRAGMENT
//#include "/lib/downscale.glsl"

#if defined EMISSIVE_MATERIAL || defined EMISSIVE_ORE
    int ore_type = int(round(ore_type_f));
    int emitter_type = int(round(emitter_type_f));
#endif

int block_type = int(round(block_type_f));

vec3 computeRealLight(vec3 omni, vec3 directColor, float directStrength, vec3 shadow, vec3 material, vec3 candle) {
    return omni + shadow * directColor * (directStrength * (1.0 + material)) * (1.0 - (rainStrength * 0.75)) + candle;
}

void main() {
    //if(fragment_cull()) discard;
    
    #if MATERIAL_GLOSS > 1 && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        float reflex_index2 = reflexIndex;
    #else
        float reflex_index2;
    #endif


    #if (defined SHADOW_CASTING && !defined NETHER) || defined DISTANT_HORIZONS || (MATERIAL_GLOSS > 0 && !defined NETHER)
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

    #if defined GBUFFER_ENTITIES && BLACK_ENTITY_FIX == 1
        vec4 block_color = texture2D(tex, texcoord);
        if(block_color.a < 0.1 && entityId != 10101) { discard; return; }
    #else
        #if RENDER_SCALE_INT != 100 && defined FSR
            vec4 block_color = texture2D(tex, texcoord);
        #else
            vec4 block_color = texture2D(tex, texcoord);
        #endif
    #endif
    
    vec4 pure_block_color = block_color;
    block_color *= tint_color;
    float block_luma = luma(block_color.rgb);
    
    #ifdef END_PORTAL
        #if defined GBUFFER_BLOCK
            if (block_type == 1){
                block_color.rgb = end_portal();
            }
        #endif
    #endif
    
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
            vec3 shadow_c = mix(get_colored_shadow(shadow_real_pos, dither), vec3(1.0), shadow_diffuse);
        #else
            vec3 shadow_c = mix(get_shadow(shadow_real_pos, dither), vec3(1.0), shadow_diffuse);
        #endif
    #else
        vec3 shadow_c = vec3(abs((light_mix * 2.0) - 1.0));
    #endif

    vec3 final_candle_color = candle_color;

    #ifdef FOLIAGE_V
        float grass = step(0.5, isGrass);
    #else
        float grass = 0.0;
    #endif

    #ifdef SHADOW_CASTING
        float directLight2;
        if(isEyeInWater == 0) {
            directLight2 = mix(direct_light_strength, (sqrt(sqrt(direct_light_strength) * 0.85) * luma(shadow_c)), grass);
        } else {
            directLight2 = mix(direct_light_strength, (direct_light_strength * 0.5 * luma(shadow_c)), grass);  
        }
    #else
        float directLight2 = direct_light_strength;
    #endif

    vec3 shadow_fol = sqrt(shadow_c);
    shadow_c = mix(shadow_c, shadow_fol, grass);

    #if defined GBUFFER_BEACONBEAM
        block_color.rgb *= block_color.rgb * 2.0 / exposure;
    #elif defined GBUFFER_ENTITY_GLOW
        block_color.rgb = clamp(gray(block_color.rgb) * vec3(0.75, 0.75, 1.5), vec3(0.3), vec3(1.0));
    #else
    
        #if (MATERIAL_GLOSS == 1 || MATERIAL_GLOSS == 3) && !defined NETHER
            float final_gloss_power = glossParms.g;
            float luma_adj = (glossParms.a == 1.0) ? block_luma : fastpow(block_luma * glossParms.b, glossParms.a);
            
            vec3 material_gloss_factor = vec3(0.0);

            float g_mask = step(0.1, glossParms.r);
            if(g_mask > 0.5){ 
                vec3 refl_vec = reflect(sub_position3_norm, flat_normal);
                material_gloss_factor = material_gloss(refl_vec, lmcoord_alt, final_gloss_power, flat_normal, mix(vec3(luma(direct_light_color)), direct_light_color, 0.5) * glossParms.r);
            }

            vec3 real_light = computeRealLight(omni_light, direct_light_color, directLight2, shadow_c, material_gloss_factor * luma_adj, candle_color);
        #else
            vec3 real_light = computeRealLight(omni_light, direct_light_color, directLight2, shadow_c, vec3(0.0), candle_color);
        #endif

        block_color.rgb *= mix(real_light, vec3(1.0), nightVision * 0.125);
        block_color.rgb *= mix(vec3(1.0), vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B), nightVision);

        // Entity Damage / Thunderbolt
        #if defined GBUFFER_ENTITIES
            if(entityId == 10101) {
                block_color = vec4(1.0, 1.0, 1.0, 0.5);
            } else {
                block_color.rgb = mix(block_color.rgb, entityColor.rgb, entityColor.a * luma(real_light) * 3.0);
            }
        #endif
        
        #if defined GBUFFER_TERRAIN || defined GBUFFER_TEXTURED || defined GBUFFER_ENTITIES
            #include "/lib/emissive_materials.glsl"
        #endif
    #endif

    #if MATERIAL_GLOSS > 1 && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        if (reflex_index2 > 0.03) { 

            float n_dot_v = dot(flat_normal, sub_position3_norm);
            float fresnel = clamp(1.0 + n_dot_v, 0.0, 1.0);
            fresnel *= fresnel;

            if (fresnel * reflexIndex > 0.005) {
                float waterMask = float(isEyeInWater != 1);
                float waterBrighness = (eyeBrightnessSmooth.y * 0.00333 + 0.2);

                vec3 sky_refl = mix(
                    hi_sky_color * (0.5 * waterBrighness), 
                    mix(low_sky_color * reflexIndex, hi_sky_color, 0.75), 
                    waterMask
                );

                block_color = solid_shader(sub_position3, flat_normal, block_color, xyz_to_rgb(sky_refl), fresnel, visible_sky, roughness, reflex_index2);
            }
        }
    #endif

    #include "/src/finalcolor.glsl"
    #include "/src/writebuffers.glsl"
}
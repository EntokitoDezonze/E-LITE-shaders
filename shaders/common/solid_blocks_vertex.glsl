#include "/lib/config.glsl"

/* Color utils */

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform sampler2D gaux3;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float light_mix;
uniform float far;
uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjectionInverse;
uniform int frameCounter;
uniform float frameTime;

#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;
#endif

#ifdef DYN_HAND_LIGHT
    uniform int heldItemId;
    uniform int heldItemId2;
#endif

#ifdef UNKNOWN_DIM
    uniform sampler2D lightmap;
#endif

#if defined FOLIAGE_V || defined THE_END || defined NETHER
    uniform mat4 gbufferModelView;
#endif

uniform mat4 gbufferModelViewInverse;

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
    uniform int worldTime;
    uniform vec3 moonPosition;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

#if WAVING == 1
    uniform vec3 cameraPosition;
    uniform float frameTimeCounter;
#endif

#if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
    uniform float endFlashIntensity;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;
varying float fog_adj;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying float block_type_f;
varying float exposure;
varying float near_fog;
varying vec3 hi_sky_color;
varying vec3 pure_low_sky_color;
varying vec3 pure_hi_sky_color;
varying vec3 low_sky_color;
varying float visible_sky;

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
    varying float roughness;
    varying float reflexIndex;
#endif


#if defined EMISSIVE_MATERIAL || defined EMISSIVE_ORE
    varying float ore_type_f;
    varying float emitter_type_f;
#endif

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    varying vec3 vWorldPos;
    varying vec3 vNormal;
    varying vec3 vBias;
#endif

#ifdef FOLIAGE_V
    varying float isFoliage;
    varying float isSeasonable;
    varying float isGrass;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 shadow_pos;
    varying float shadow_diffuse;
#endif

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
    varying vec3 flat_normal;
    varying vec3 sub_position3;
    varying vec3 sub_position3_norm;
    varying vec2 lmcoord_alt;
    varying vec4 glossParms; // AMD fix

    float gloss_factor;
    float gloss_power;
    float luma_factor;
    float luma_power;
#endif

varying float sunInfluence;

attribute vec4 mc_Entity;
attribute int blockEntityId;

#if WAVING == 1
    attribute vec2 mc_midTexCoord;
#endif

/* Utility functions */

#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

#if WAVING == 1
    #include "/lib/vector_utils.glsl"
#endif

#include "/lib/luma.glsl"
#include "/lib/seasons.glsl"

#define FOG_BIOME
#include "/lib/biome_sky.glsl"
//#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    exposure = texture2D(gaux3, vec2(0.5)).r;
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
    int mc_ex = int(mc_Entity.x); 

    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"

    vec3 dirToView = normalize(sub_position.xyz);

    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"
    #include "/src/light_vertex.glsl"
    #include "/src/fog_vertex.glsl"

    #if defined SHADOW_CASTING && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"
        
        #if SHADOW_LOCK > 0
            vNormal = shadow_world_normal;
            vBias = bias;
        #endif
    #endif

    #if defined GBUFFER_BLOCK
        block_type_f = (blockEntityId == 10091) ? 1.0 : 0.0;
    #endif

    #if defined EMISSIVE_ORE
        ore_type_f = (mc_ex >= 9000 && mc_ex <= 9007) ? float(mc_ex - 8999) : 0.0;
    #endif

    #if defined EMISSIVE_MATERIAL
        float temp_emitter = 0.0;
        
        if (mc_ex >= 9008 && mc_ex <= 9013) {
            temp_emitter = float(mc_ex - 9007);
        } else if (mc_ex == 9014) {
            temp_emitter = 10.0;
        } else if (mc_ex == 9015) {
            temp_emitter = 11.0;
        } else if (mc_ex >= 10089) {
            if (mc_ex == 10090)           temp_emitter = 7.0;
            else if (mc_ex == 10089)      temp_emitter = 8.0;
            else if (mc_ex >= 10213 && mc_ex <= 10214) temp_emitter = 9.0;
        }
        
        emitter_type_f = temp_emitter;
    #endif

    #if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
        luma_factor = 1.0;
        luma_power = 1.0;
        gloss_power = 2.0;
        gloss_factor = 0.0;
        roughness = 0.0;
        reflexIndex = 0.0;

        if (mc_ex >= 10400) {
            if (mc_ex == 10400) { // Metals
                luma_factor = 1.3; luma_power = 20.0; 
                gloss_power = 50.0; gloss_factor = 1.5; 
                roughness = 1.75; reflexIndex = 0.65;
            } 
            else if (mc_ex <= 10411) { // Sand and Stone (10410, 10411)
                bool is_sand = (mc_ex == 10410);
                luma_factor = is_sand ? 1.05 : 1.75;
                luma_power  = is_sand ? 12.0 : 8.0;
                gloss_power = 4.0;
                gloss_factor = is_sand ? 2.5 : 1.0;
            }
            else if (mc_ex == 10415) { // White Gloss
                gloss_power = 1.5; gloss_factor = 0.75;
            }
            else if (mc_ex <= 10430) { // Polished (10420, 10421) and Rough (10430)
                luma_factor = (mc_ex == 10421) ? 2.0 : 1.75;
                luma_power  = (mc_ex == 10430) ? 10.0 : 6.0;
                gloss_power = (mc_ex == 10421) ? 20.0 : 15.0;
                gloss_factor = (mc_ex == 10420) ? 3.0 : (mc_ex == 10430 ? 0.3 : 0.2);
                roughness = 3.0; reflexIndex = 0.333;
            }
            else if (mc_ex == 10440) { // Fabric
                luma_factor = 3.0; luma_power = 2.0; gloss_power = 3.0;
            }
            else if (mc_ex == 10450) { // Concrete
                luma_factor = 6.5; luma_power = 0.5; gloss_power = 15.0;
                gloss_factor = 1.0; roughness = 2.0; reflexIndex = 0.25;
            }
        } 
        // Foliage
        else if (mc_ex >= 10018 && mc_ex <= 10019) {
            luma_factor = (mc_ex == 10018) ? 4.5 : 2.5;
            luma_power = 1.5;
            gloss_power = 1.0;
            gloss_factor = 1.0;
        }
        // Portal
        else if (mc_ex == 9015 || blockEntityId == 10091) {
            roughness = 0.5; reflexIndex = 0.5;
            if(blockEntityId == 10091) { roughness = 1.0; reflexIndex = 1.0; }
        }

        flat_normal = normal;
        sub_position3 = sub_position.xyz;
        sub_position3_norm = dirToView;
        lmcoord_alt = lmcoord;

        glossParms.r = gloss_factor;
        glossParms.g = gloss_power;
        glossParms.b = luma_factor;
        glossParms.a = luma_power;
    #endif

    #ifdef FOLIAGE_V
        isGrass = (mc_ex >= ENTITY_SMALLGRASS && mc_ex <= ENTITY_UPPERGRASS) ? 1.0 : 0.0;
    #endif

    #if defined GBUFFER_ENTITY_GLOW
        gl_Position.z *= 0.01;
    #endif

    #if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
        vNormal = shadow_world_normal;
        vBias = bias;
    #endif
}
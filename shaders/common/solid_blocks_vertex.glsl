#include "/lib/config.glsl"

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */
uniform sampler2D gaux3, lightmap;
uniform float viewWidth, viewHeight, light_mix, far, rainStrength, wetness, frameTime, endFlashIntensity;
uniform int isEyeInWater, frameCounter;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
uniform vec3 moonPosition, sunPosition, skyColor;

#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;
#endif

#ifdef VOXY
    uniform int vxRenderDistance;
#endif

#if defined FOLIAGE_V || defined THE_END || defined NETHER
    uniform mat4 gbufferModelView;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 shadowModelView, shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

#if WAVING == 1
    uniform vec3 cameraPosition;
    uniform float frameTimeCounter;
#endif

/* Ins / Outs */
varying vec2 texcoord;
varying vec4 tint_color;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying vec3 omni_light;
vec3 hi_sky_color;
vec3 pure_low_sky_color;
vec3 pure_hi_sky_color;
vec3 low_sky_color;

// Pack A
float fog_adj;
float direct_light_strength;
float block_type_f;
float exposure;

// Pack B
float near_fog;
float visible_sky;
float sunInfluence;
float roughness;

// Emissive Pack
float ore_type_f;
float emitter_type_f;

// Foliage Pack
float isFoliage;
float isSeasonable;
float isGrass;

varying vec4 data_pack_a; // x: fog_adj, y: direct_light_strength, z: block_type_f, w: exposure
varying vec4 data_pack_b; // x: near_fog, y: visible_sky, z: sunInfluence, w: roughness
varying vec2 emissiveData; // x: ore_type_f, y: emitter_type_f
varying vec3 foliageData; // x: isFoliage, y: isSeasonable, z: isGrass
varying float vanilla_ao;

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
    varying vec2 lmcoord_alt;
    varying vec4 glossParms; 
    varying float reflexIndex;
#endif

#if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1 || defined LabPBR
    varying vec3 sub_position3, sub_position3_norm;
    
#endif
varying vec3 flat_normal;

#if defined SHADOW_CASTING && !defined NETHER
    vec3 shadow_pos;
    float shadow_diffuse;
    varying vec4 shadowParms;
#endif

#ifdef DYN_HAND_LIGHT
    uniform int heldItemId;
    uniform int heldItemId2;
#endif
uniform int currentRenderedItemId;

attribute vec4 mc_Entity;
attribute int blockEntityId;

#if WAVING == 1 || defined LabPBR
    attribute vec2 mc_midTexCoord;
#endif

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

#if defined LabPBR && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
    attribute vec4 at_tangent;
    varying vec4 vDistTg;
    varying vec4 atlas_uv;
    varying vec2 local_uv;
    varying mat3 tbn;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 vNormal, vBias, vWorldPos;
#endif

void main() {
    float exposure_v = texture2D(gaux3, vec2(0.5)).r;
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
    int mc_ex = int(mc_Entity.x); 
    vanilla_ao = gl_Color.a;

    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"

    vec3 dirToView = normalize(sub_position.xyz);

    #include "/src/hi_sky.glsl"
    #include "/src/low_sky.glsl"
    #include "/src/light_vertex.glsl"
    #include "/src/fog_vertex.glsl"
    
    #if defined LabPBR && (defined GBUFFER_TERRAIN || defined GBUFFER_BLOCK)
        vec2 mid_uv = (gl_TextureMatrix[0] * vec4(mc_midTexCoord.st, 0.0, 1.0)).st;
        vec2 diff = texcoord - mid_uv;
        atlas_uv.xy = min(texcoord, mid_uv - diff);
        atlas_uv.zw = abs(diff) * 2.0;
        local_uv = sign(diff) * 0.5 + 0.5;

        vec3 n = normalize(gl_NormalMatrix * gl_Normal);
        vec3 t = normalize(gl_NormalMatrix * at_tangent.xyz);
        vec3 b = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);

        tbn = mat3(t, b, n);      
        vec3 pos_view = (gl_ModelViewMatrix * gl_Vertex).xyz;
        vec3 view_tg = vec3(dot(pos_view, t), dot(pos_view, b), dot(pos_view, n));
        float vdist = length(pos_view);
        vDistTg = vec4(view_tg, vdist);
    #endif

    #if defined SHADOW_CASTING && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"

        #if SHADOW_LOCK > 0
            vNormal = shadow_world_normal;
            vBias = bias;
        #endif
        shadowParms = vec4(shadow_pos, shadow_diffuse);
    #endif

    float block_type_v = 0.0;
    #if defined GBUFFER_BLOCK
        if(blockEntityId == 10091) block_type_v = 1.0;
        if(blockEntityId == 10400) block_type_v = 2.0;
    #endif

    float ore_v = 0.0;
    float emitter_v = 0.0;
    #if defined EMISSIVE_ORE
        ore_v = (mc_ex >= 9000 && mc_ex <= 9007) ? float(mc_ex - 8999) : 0.0;
    #endif

    #if defined EMISSIVE_MATERIAL
        float temp_emitter = 0.0;
        if (mc_ex >= 9008 && mc_ex <= 9013) temp_emitter = float(mc_ex - 9007);
        else if (mc_ex == 10090) temp_emitter = 7.0;
        else if (mc_ex == 10089) temp_emitter = 8.0;
        else if (mc_ex >= 10213 && mc_ex <= 10214) temp_emitter = 9.0;
        else if (mc_ex == 9014) temp_emitter = 10.0;
        else if (mc_ex == 9015) temp_emitter = 11.0;  
        else if(currentRenderedItemId == 9016) temp_emitter = 12.0;
        else if (mc_ex == 9017) temp_emitter = 13.0;
        else if (mc_ex == 9018) temp_emitter = 14.0;

        emitter_v = temp_emitter;
    #endif

    float roughness_v = 0.0;
    float reflex_v = 0.0;
    float g_fact = 2.0; float g_pow = 3.5; float l_fact = 10.0; float lpow = 3.0;

    #if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1
        if (mc_ex >= 10400) {
            if (mc_ex == 10400) { // Metals
                l_fact = 1.2; l_pow = 40.0; g_pow = 50.0; g_fact = 1.5; roughness_v = 1.75; reflex_v = 0.65;
            } else if (mc_ex <= 10411) { // Sand and Stone
                bool is_sand = (mc_ex == 10410);
                l_fact = is_sand ? 1.4 : 2.0; l_pow = 10.0; g_pow = 4.0; g_fact = is_sand ? 2.5 : 2.0;
            } else if (mc_ex <= 10430 && mc_ex >= 10420) { // Polished/Rough
                l_fact = 8.0; l_pow = (mc_ex == 10430) ? 4.0 : 2.25; g_pow = (mc_ex == 10421) ? 10.0 : 1.0;
                g_fact = (mc_ex == 10420) ? 3.0 : (mc_ex == 10430 ? 0.05 : 0.2); roughness_v = 3.0; reflex_v = 0.333;
            } else if (mc_ex == 10450) { // Concrete
                l_fact = 7.5; l_pow = 1.0; g_pow = 1.0; g_fact = 5.0; roughness_v = 2.0; reflex_v = 0.25;
            }
        } else if (mc_ex >= 10018 && mc_ex <= 10019) { // Foliage
            l_fact = (mc_ex == 10018) ? 20.0 : 2.5; l_pow = 1.5; g_pow = 0.5; g_fact = 1.0;
        }
        lmcoord_alt = lmcoord;
        glossParms = vec4(g_fact, g_pow, l_fact, l_pow);
        reflexIndex = reflex_v;
    #endif

    #if (MATERIAL_GLOSS > 0 && !defined NETHER) || MATERIAL_GLOSS > 1 || defined LabPBR
        sub_position3 = sub_position.xyz;
        sub_position3_norm = dirToView;
        flat_normal = normal;
    #endif

    #ifdef FOLIAGE_V
        isGrass = (mc_ex >= ENTITY_SMALLGRASS && mc_ex <= ENTITY_UPPERGRASS) ? 1.0 : 0.0;
    #endif

    #if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
        vNormal = shadow_world_normal;
        vBias = bias;
    #endif

    data_pack_a = vec4(fog_adj, direct_light_strength, block_type_v, exposure_v);
    data_pack_b = vec4(near_fog, visible_sky, sunInfluence, roughness_v);
    emissiveData = vec2(ore_v, emitter_v);
    foliageData = vec3(0.0, 0.0, isGrass);
}
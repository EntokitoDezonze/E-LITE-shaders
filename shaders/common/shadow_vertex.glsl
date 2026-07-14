#include "/lib/config.glsl"


// == Uniforms
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    uniform vec3 shadowLightPosition;
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferModelView;
#endif

// == Varyings
varying vec2 texcoord;
varying float is_noshadow;
varying vec3 worldPos;
varying float is_water;

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    varying vec3 vWorldPos;
    varying vec3 vNormal;
    varying vec3 vBias;
#endif

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

attribute vec4 mc_Entity;

// == Main function

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    vec4 position = shadowModelViewInverse * shadowProjectionInverse * gl_ModelViewProjectionMatrix * gl_Vertex;
    gl_Position = shadowProjection * shadowModelView * position;

    vec4 positions = shadowModelViewInverse * shadowProjectionInverse * ftransform();
    worldPos = positions.xyz;
    vec3 normal = gl_NormalMatrix * gl_Normal;
    vec3 shadow_pos;
    float shadow_diffuse;

    #if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"
    #endif

    float p = 4.0;
    float dist = pow(pow(abs(gl_Position.x), p) + pow(abs(gl_Position.y), p), 1.0 / p);

    float falloff = 1.0 / (1.0 + dist * 0.1);
    float distortFactor = mix(1.0, dist, SHADOW_DIST * falloff);

    gl_Position.xy /= min(distortFactor, 0.75);
    gl_Position.z = gl_Position.z * 0.2;

    is_noshadow = 0.0;
    if (mc_Entity.x == ENTITY_NO_SHADOW_FIRE || mc_Entity.x == ENTITY_F_EMMISIVE) {
        is_noshadow = 1.0;
    }

    #ifdef COLORED_SHADOW
        is_water = 0.0;

        if(mc_Entity.x == ENTITY_WATER) {
            is_water = 1.0;
        }
    #endif

    #if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
        vWorldPos = position.xyz;
        vNormal = shadow_world_normal;
        vBias = bias;
    #endif
}

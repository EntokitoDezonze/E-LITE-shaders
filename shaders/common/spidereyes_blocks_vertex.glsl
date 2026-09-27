#include "/lib/config.glsl"

// == Uniforms
uniform mat4 gbufferProjectionInverse;
uniform float frameTime;

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 gbufferModelViewInverse;
#endif

// == Varyings
varying vec2 texcoord;

// == Utility
#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

//#include "/lib/downscale.glsl"
 
// == Main function

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    #include "/src/position_vertex.glsl"
    //resize_vertex(gl_Position);
}
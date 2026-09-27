#include "/lib/config.glsl"

// == Uniforms
uniform sampler2D gaux3;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform float frameTime;

// == Varyings
varying vec2 texcoord;
varying vec4 tint_color;
varying float exposure;

#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

// == Main function

void main() {
    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"

        exposure = texture2D(gaux3, vec2(0.5)).r;

    tint_color = gl_Color;
}

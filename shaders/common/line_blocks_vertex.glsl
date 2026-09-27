#include "/lib/config.glsl"

// == Uniforms
uniform float viewHeight;
uniform float viewWidth;
uniform int frameCounter;
uniform float frameTime;
// == Varyings
varying vec4 tint_color;

#ifdef RGB_LINE
    varying vec3 pos;
#endif

// == Utility
#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/mu_ftransform.glsl"
//#include "/lib/downscale.glsl"

// == Main function

void main() {
    tint_color = gl_Color;
    gl_Position = mu_ftransform();
    #ifdef RGB_LINE
        pos = gl_Position.xyz;
    #endif
    //resize_vertex(gl_Position);

    #if AA_TYPE > 1
        gl_Position.xy += taa_offset * gl_Position.w;
    #endif
}

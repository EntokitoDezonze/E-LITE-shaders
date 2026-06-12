#include "/lib/config.glsl"

#ifdef DOF
    const bool colortex1MipmapEnabled = true;
#endif

#ifdef BLOOM
    const bool colortex2MipmapEnabled = true;
#endif

/* Uniforms */

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform float inv_aspect_ratio;
uniform float frameTime;
uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;

#ifdef DOF
    uniform float centerDepthSmooth;
    uniform float fov_y_inv;
#endif

#ifdef BLOOM
    uniform float softLod;
#endif

#if defined DOF || defined MOTION_BLUR
    uniform float pixel_size_x;
    uniform float pixel_size_y;
#endif

#if AA_TYPE > 0 || defined MOTION_BLUR
    uniform sampler2D colortex3;  // TAA past averages
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferModelViewInverse;
    uniform vec3 cameraPosition;
    uniform vec3 previousCameraPosition;
    uniform mat4 gbufferPreviousProjection;
    uniform mat4 gbufferPreviousModelView;
    uniform sampler2D depthtex1;
#endif

/* Ins / Outs */

varying vec2 texcoord;

/* Utility functions */
#define FRAGMENT
//#include "/lib/downscale.glsl"

#if defined BLOOM || defined DOF
    #include "/lib/dither.glsl"
#endif

#include "/lib/luma.glsl"
#include "/lib/bloom.glsl"

#ifdef DOF
    #include "/lib/blur.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    //if(fragment_cull()) discard;
    vec4 block_color = texture2DLod(colortex1, texcoord, 0);

    #if defined BLOOM || defined DOF
        #if AA_TYPE > 0
            float dither = shifted_eclectic_r_dither(gl_FragCoord.xy);
        #else
            float dither = semiblue(gl_FragCoord.xy);
        #endif
    #endif
    
    #ifdef DOF
        block_color.rgb = noised_blur(block_color, colortex1, texcoord, DOF_STRENGTH, dither);
    #endif

    #ifdef BLOOM
        vec3 bloom = mipmap_bloom(colortex2, texcoord, dither);
        block_color.rgb += bloom;
    #endif

    block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
}

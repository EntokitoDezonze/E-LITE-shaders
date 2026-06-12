// E-LITE shaders 5 - Prepare_fragment.glsl
// Sky colors.

#include "/lib/config.glsl"
#include "/lib/luma.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform mat4 gbufferProjectionInverse;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float rainStrength;
uniform float wetness;
uniform vec3 sunPosition;
uniform float eyeAltitude;
uniform float light_mix;
uniform vec4 lightningBoltPosition;
uniform float frameTime;
uniform float near;
uniform float far;
uniform float dhNearPlane;
uniform float dhFarPlane;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;
uniform ivec2 eyeBrightnessSmooth;
uniform sampler2D dhDepthTex0;

/* Ins / Outs */

varying vec3 up_vec;
varying vec2 texcoord;
varying vec3 hi_sky_color;
varying vec3 mid_sky_color;
varying vec3 low_sky_color;
varying vec3 pure_hi_sky_color;
varying vec3 pure_mid_sky_color;
varying vec3 pure_low_sky_color;
varying vec4 position;

/* Utility functions */

#include "/lib/dither.glsl"
#include "/lib/biome_sky.glsl"
#include "/lib/basic_utils.glsl"

#ifdef THE_END
    #include "/lib/render_aux.glsl"
    #include "/lib/stars.glsl"
    #include "/lib/depth_dh.glsl"
#endif

#define FRAGMENT
//#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    //if(fragment_cull()) discard;
    #if defined THE_END 
        #ifdef DISTANT_HORIZONS
            float d = texture2DLod(dhDepthTex0, texcoord, 0.0).r;
            float ld = ld_dh(d);
        #else
            float d = 1.0;
            float ld = d;
        #endif

        vec4 star_color;
        if(ld > 0.99){
            star_color = vec4(stars(), 1.0);
        } else {
            star_color = vec4(0.0);
        }
        vec3 block_color = ZENITH_DAY_COLOR + star_color.rgb;
    #elif defined NETHER
        vec3 block_color = ZENITH_DAY_COLOR;
    #else
        #include "/src/get_sky.glsl"
        block_color = saturate(block_color, 0.85);
    #endif

    #include "/src/writebuffers.glsl"
}
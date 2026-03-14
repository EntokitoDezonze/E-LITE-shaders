#include "/lib/config.glsl"
#include "/lib/luma.glsl"


// Do not remove comments. It works!
/*

noisetex - Water normals
colortex0 - Unused
colortex1 - Antialiasing auxiliar
colortex2 - Bloom auxiliar
colortex3 - TAA Averages history
gaux1 - Screen-Space-Reflection
gaux2 - Clouds texture: natural and vanilla
gaux3 - Exposure auxiliar
gaux4 - Fog auxiliar

const int noisetexFormat = RG8;
const int colortex0Format = R8;
*/
#ifdef DOF
    #ifdef DOF_HDR // COLOR_BITS does not affect HDR.
        /*
        const int colortex1Format = RGBA16F;
        */
    #else
        #if COLOR_BITS == 8
        /*
        const int colortex1Format = RGBA8;
        */
        #elif COLOR_BITS == 10
        /*
        const int colortex1Format = RGB10_A2;
        */
        #elif COLOR_BITS == 16
        /*
        const int colortex1Format = RGBA16;
        */
        #endif
    #endif
#else
    #ifdef HDR
        /*
        const int colortex1Format = R11F_G11F_B10F;
        */
    #else
        #if COLOR_BITS == 8
        /*
        const int colortex1Format = RGBA8;
        */
        #elif COLOR_BITS == 10
        /*
        const int colortex1Format = RGB10_A2;
        */
        #elif COLOR_BITS == 16
        /*
        const int colortex1Format = RGBA16;
        */
        #endif
    #endif
#endif

#ifdef DOF
    #ifdef DOF_HDR // COLOR_BITS does not affect HDR.
        /*
        const int colortex3Format = RGBA16F;
        */
    #else
        #if COLOR_BITS == 8
        /*
        const int colortex3Format = RGBA8;
        */
        #elif COLOR_BITS == 10
        /*
        const int colortex3Format = RGBA8;
        */
        #elif COLOR_BITS == 16
        /*
        const int colortex3Format = RGBA16;
        */
        #endif
    #endif
#else
    #ifdef HDR
        /*
        const int colortex3Format = R11F_G11F_B10F;
        */
    #else
        #if COLOR_BITS == 8
        /*
        const int colortex3Format = RGBA8;
        */
        #elif COLOR_BITS == 10
        /*
        const int colortex3Format = RGB10_A2;
        */
        #elif COLOR_BITS == 16
        /*
        const int colortex3Format = RGBA16;
        */
        #endif
    #endif
#endif
/*
const int gaux1Format = RGBA8;
const int gaux2Format = R8;
const int gaux3Format = R16F;
const int gaux4Format = R11F_G11F_B10F;

const int shadowcolor0Format = RGBA8;
*/

// Buffers clear
const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool gaux1Clear = false;
const bool gaux2Clear = false;
const bool gaux3Clear = false;
const bool gaux4Clear = false;

/* Uniforms */

#ifdef DEBUG_MODE
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D colortex3;
#endif

uniform sampler2D gaux3;
uniform sampler2D gaux1;
uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;
uniform float frameTimeCounter;
uniform int isEyeInWater;
uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;
uniform float near;
uniform float far;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform sampler2D depthtex1;
uniform float frameTime;

/* Ins / Outs */

varying vec2 texcoord;
varying float exposure;

/* Utility functions */

#include "/lib/basic_utils.glsl"
#include "/lib/tone_maps.glsl"
#include "/lib/dither.glsl"

#ifdef COLOR_BLINDNESS
    #include "/lib/color_blindness.glsl"
#endif

#ifdef CHROMA_ABER
    #include "/lib/aberration.glsl"
#endif

#include "/lib/day_blend.glsl"

// Vignette, Film grain, Sharpening and Fake bloom.
#if defined VIGNETTE || defined FAKE_BLOOM || defined FILM_GRAIN || defined COLOR_BLINDNESS || AA_TYPE == 3
    #include "/lib/post_processing.glsl"    
#endif


#ifdef FXAA
    #include "/lib/fxaa.glsl"
#endif

#define FRAGMENT
//#include "/lib/downscale.glsl"

#include "/lib/textRender/textRender.glsl"

void main() {
    vec2 pixelUV = texcoord;

    #ifdef PS1_LIKE
        pixelUV = floor(texcoord * vec2(viewWidth, viewHeight) / PIXEL_SIZE) * PIXEL_SIZE / vec2(viewWidth, viewHeight) * RENDER_SCALE;
    #endif // PS1 filter

    #ifdef CHROMA_ABER
        vec3 block_color = color_aberration();
        #if defined FXAA && !defined PS1_LIKE
            block_color = fxaa311(block_color, 6, pixelUV);
        #endif
    #else
       vec3 block_color = texture2DLod(colortex1, pixelUV, 0.0).rgb;
        #if defined FXAA && !defined PS1_LIKE
            block_color = fxaa311(block_color, 6, pixelUV);
        #endif

       #if AA_TYPE == 3 && !defined PS1_LIKE
            block_color = sharpen(colortex1, block_color, pixelUV);
        #endif   
    #endif

    // Fake Purkinje shift
    if (isEyeInWater == 1) {
        float luma_factor = luma(block_color);
        float shadow_desaturation = smoothstep(0.01, 0.455, luma_factor);
        block_color = mix(block_color, block_color * vec3(0.8, 1.3, 1.6), shadow_desaturation);
    } else {
        float luma_factor = luma(block_color);

        float shadow_desaturation = smoothstep(0.02, 0.25, luma_factor);
        vec3 shadow_tint = vec3(0.9, 0.94, 1.0);

        block_color = mix(saturate(block_color, 0.75) * shadow_tint, block_color, shadow_desaturation);
    } // Water overlay

    #if defined SIMPLE_AUTOEXP && COLOR_SCHEME != 4
        float exposure_final = day_blend_float(1.5, 0.85, 3.5);
    #elif COLOR_SCHEME == 4 && defined SIMPLE_AUTOEXP
        float exposure_final = day_blend_float(0.5, 0.5, 2.0);
    #elif COLOR_SCHEME == 4 && !defined SIMPLE_AUTOEXP
        float exposure_final = exposure * day_blend_float(0.8, 1.0, 1.0);
    #else
        // Dynamic exposure curve.
        float start = 1.0;
        float end   = 2.0;
        float minPow = 0.8;

        float releaseStart = 2.25;
        float releaseEnd   = 2.75;

        float tCompress = smoothstep(start, end, exposure);
        float tRelease = smoothstep(releaseStart, releaseEnd, exposure);

        float t = tCompress * (1.0 - tRelease);
        float dynamicPow = mix(1.0, minPow, t);

        float exposure_final = pow(exposure, dynamicPow);
    #endif

    block_color *= vec3(RED, GREEN, BLUE) * vec3(exposure_final * EXPOSURE) * BRIGHTNESS; // Color balance, Exposure, Brightness. 
    block_color = (block_color - 0.5) * CONTRAST + 0.5; // Contrast
    block_color = saturate(block_color.rgb, SATURATION); // Saturation
    block_color = vibrance(block_color.rgb, VIBRANCE); // Vibrance
    block_color = pow(block_color.rgb, vec3(1 / GAMMA)); // Gamma

    #ifdef TITLE
        float lifeSpan = 4.5;
        float textOpacity = 1.0 - smoothstep(4.0, lifeSpan, frameTimeCounter);

        float mainScale = 6.0;
        int mainTotalWidth = 96; // 16 chars * 6px

        ivec2 fragPosMain = ivec2(gl_FragCoord.xy / mainScale);
        int centerX = int((viewWidth / mainScale) * 0.5);
        ivec2 textPosMain = ivec2(centerX - (mainTotalWidth / 2), int((viewHeight * 0.825 + 50) / mainScale));
        #include "/src/textRender/splashScreen.glsl"
    #endif

    #if !defined SHADOW_CASTING && VOL_LIGHT == 2
        block_color *= 0.0;
        #include "/src/textRender/godrayError.glsl"
    #endif

    #if TONEMAPPING == 0
        block_color = custom_sigmoid_alt(block_color);
    #elif TONEMAPPING == 1
        #ifdef HDR
            block_color = Lottes(block_color, 1.75);
        #else
            block_color = Lottes(block_color, 1.3);
        #endif
    #elif TONEMAPPING == 2
        block_color = ACESFilm(block_color, 2.6);
    #elif TONEMAPPING == 3
        block_color = Lottes(block_color, 0.1);
    #elif TONEMAPPING == 4
        block_color = uchimura_tm(block_color);
    #endif    

    #ifdef VIGNETTE
        block_color *= vignette(texcoord); // Vignette
    #endif

    #ifdef FAKE_BLOOM
        float threshold = 0.5; 
        block_color = fakeBloom(block_color, threshold); // Fake Bloom
    #endif
    
    #ifdef FILM_GRAIN
        float grainIntensity = GRAIN_FACTOR; 
        block_color = filmGrain(block_color, grainIntensity, texcoord); // Film grain
    #endif

    #ifdef COLOR_BLINDNESS
        block_color = color_blindness(block_color); // Color Blindness
    #endif

    #ifdef DEBUG_MODE
        if(texcoord.x < 0.5 && texcoord.y < 0.5) {
            block_color = texture2D(shadowtex1, texcoord * 2.0).rrr;
        } else if(texcoord.x >= 0.5 && texcoord.y >= 0.5) {
            block_color = vec3(texture2D(gaux3, vec2(0.5)).r * 0.25);
        } else if(texcoord.x < 0.5 && texcoord.y >= 0.5) {
            block_color = texture2D(colortex1, ((texcoord - vec2(0.0, 0.5)) * 2.0)).rgb;
        } else if(texcoord.x >= 0.5 && texcoord.y < 0.5) {
            block_color = texture2D(shadowcolor0, ((texcoord - vec2(0.5, 0.0)) * 2.0)).rgb;
        } else {
            block_color = vec3(0.5);
        }

        gl_FragData[0] = vec4(block_color, 1.0);

    #else
        gl_FragData[0] = vec4(block_color, 1.0);
    #endif
}
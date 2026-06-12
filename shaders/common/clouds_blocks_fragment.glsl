#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;
uniform float far;
uniform float near;
uniform float blindness;
uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferProjectionInverse;
uniform mat4 dhProjectionInverse;
uniform float rainStrength;

#if MC_VERSION >= 11900
    uniform float darknessFactor;
    uniform float darknessLightFactor;
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    uniform float pixel_size_x;
    uniform float pixel_size_y;
    uniform sampler2D gaux4;
#endif

uniform sampler2D depthtex0;

#if defined DISTANT_HORIZONS
    uniform sampler2D dhDepthTex0;
    uniform float dhNearPlane;
    uniform float dhFarPlane;
#endif

/* Ins / Outs */

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    varying vec2 texcoord;
    varying vec4 tint_color;
#endif

#include "/lib/day_blend.glsl"
#include "/lib/luma.glsl"
#ifdef DISTANT_HORIZONS
    #include "/lib/depth_dh.glsl"
    #include "/lib/depth.glsl"
#endif

#define FRAGMENT
//#include "/lib/downscale.glsl"

// Main function ---------

void main() {
    #if V_CLOUDS == 0 || defined UNKNOWN_DIM
        #ifdef DISTANT_HORIZONS
            vec2 screenCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
            vec4 cloudClipPos = vec4(screenCoord * 2.0 - 1.0, gl_FragCoord.z * 2.0 - 1.0, 1.0);
            vec4 cloudViewPos = gbufferProjectionInverse * cloudClipPos;
            cloudViewPos /= cloudViewPos.w;
            float distCloud = length(cloudViewPos.xyz);
        #else
            float distCloud = 0.0;
        #endif

        #ifdef DISTANT_HORIZONS
            float depthDH = texture2D(dhDepthTex0, screenCoord).r;
            vec4 dhClipPos = vec4(screenCoord * 2.0 - 1.0, depthDH * 2.0 - 1.0, 1.0);
            vec4 dhViewPos = dhProjectionInverse * dhClipPos;
            dhViewPos /= dhViewPos.w;
            float distDH = mix(length(dhViewPos.xyz), 100000.0, step(1.0, depthDH));
        #else
            float distDH = 100000.0;
        #endif

        float occlusion = step(distCloud, distDH);

        vec4 block_color = texture2D(tex, texcoord * RENDER_SCALE) * tint_color;
        
        #if COLOR_SCHEME == 4
            block_color.rgb *= dayBF(1.0, 1.9, 0.25);
            block_color.rgb = mix(gray(block_color.rgb), block_color.rgb, dayBF(1.0, 0.0, 0.5));
        #elif COLOR_SCHEME == 2
            block_color.rgb *= dayBF(0.4, mix(1.25, 0.6, rainStrength), 0.333);
            block_color.a *= mix(1.0, 0.333, rainStrength);
            block_color.rgb *= mix(vec3(1.0), dayBlend(vec3(0.65, 0.8, 1.0), vec3(0.65, 0.8, 1.0), vec3(1.0)), rainStrength);
        #elif COLOR_SCHEME == 5
            block_color.rgb *= dayBF(0.05, 0.1, 0.025);
        #endif

        block_color.a *= occlusion;
        block_color.rgb *= 0.8;

        #include "/src/cloudfinalcolor.glsl"
        #include "/src/writebuffers.glsl"
    #elif MC_VERSION <= 11300
        vec4 block_color = vec4(0.0);
        #include "/src/writebuffers.glsl"
    #endif
}

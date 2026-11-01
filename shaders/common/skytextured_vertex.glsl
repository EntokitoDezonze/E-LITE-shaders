#include "/lib/config.glsl"

// == Color utils
#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

// == Varyings
varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;
varying vec3 cursed_sky;
varying float current_wetness;
varying vec3 astro_world_dir;

#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

// == Uniforms
uniform float rainStrength;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform int renderStage;
uniform float viewWidth; 
uniform float viewHeight; 
uniform int frameCounter;
uniform float frameTime;

// == Utility
#include "/lib/luma.glsl"
//#include "/lib/downscale.glsl"

// == Main function

void main() {
    
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    tint_color = gl_Color;

    #ifndef CUSTOM_SKYFIX
        sky_luma_correction = luma(dayBlend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR));

        current_wetness = 1 - rainStrength;

        #if COLOR_SCHEME == 5
            cursed_sky = dayBlend(vec3(2.0), vec3(1.0), vec3(4.0, 0.5, 0.5));
            sky_luma_correction *= dayBF(0.5, 0.0, 1.0);
        #endif

        sky_luma_correction *= dayBF(SUN_MUL, SUN_MUL, MOON_MUL);
    #else
        sky_luma_correction = 1.0;
        cursed_sky = vec3(1.0);
        current_wetness = 1 - rainStrength;
    #endif


    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    //resize_vertex(gl_Position);

    astro_world_dir = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz;

    #if AA_TYPE > 1
        gl_Position.xy += taa_offset * gl_Position.w;
    #endif
}

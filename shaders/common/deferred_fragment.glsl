#include "/lib/config.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform sampler2D colortex1;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float far;
uniform float near;
uniform float blindness;
uniform float rainStrength;
uniform float wetness;
uniform sampler2D gaux3;
uniform float viewWidth;
uniform float viewHeight;

#if V_CLOUDS > 0 || AURORA > 0
    uniform sampler2D gaux2;
    uniform sampler2D colortex2;
#endif

#if AO == 1
    uniform float inv_aspect_ratio;
    uniform float fov_y_inv;
#endif

#if V_CLOUDS > 0 && !defined UNKNOWN_DIM || AURORA > 0
    uniform sampler2D noisetex;
    uniform vec3 cameraPosition;
#endif

#if (V_CLOUDS > 0 && !defined UNKNOWN_DIM || AURORA > 0) || ROUND_SUN < 2
    uniform vec3 sunPosition;
#endif
    
#if defined DISTANT_HORIZONS
    uniform sampler2D dhDepthTex0;
    uniform float dhNearPlane;
    uniform float dhFarPlane;
#endif

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float frameTime;

#if AO == 1 || (V_CLOUDS > 0 && !defined UNKNOWN_DIM) || AURORA > 0
    uniform mat4 gbufferProjection;
    uniform float frameTimeCounter;
    uniform int frameCounter;
#endif
/* Ins / Outs */

varying vec2 texcoord;
varying vec3 up_vec;  // Flat
varying vec3 direct_light_color;
varying vec3 direct_light_strength;

#if (V_CLOUDS > 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY || AURORA > 0
    varying float umbral;
    varying float dynamicValue;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

#if AO == 1
    varying float fog_density_coeff;
    #ifdef DISTANT_HORIZONS
        varying float sunInfluence;
    #endif
#endif

/* Utility functions */ 

#include "/lib/depth.glsl"
#include "/lib/luma.glsl"
#include "/lib/fps_correction.glsl"
#include "/lib/basic_utils.glsl"

#ifdef DISTANT_HORIZONS
    #include "/lib/depth_dh.glsl"
#endif

#if !defined THE_END && !defined NETHER && ROUND_SUN < 2
    #include "/lib/render_aux.glsl"
    #include "/lib/round_sun.glsl"
#endif

#if AO == 1 || (V_CLOUDS > 0 && !defined UNKNOWN_DIM) || AURORA > 0
    #include "/lib/dither.glsl"
#endif

#if AO == 1
    #include "/lib/ao.glsl"
#endif

#include "/lib/biome_sky.glsl"

#if (V_CLOUDS > 0 && !defined UNKNOWN_DIM) || AURORA > 0
    #include "/lib/projection_utils.glsl"

    #ifdef THE_END
        #include "/lib/volumetric_clouds_end.glsl"
    #else
        #include "/lib/volumetric_clouds.glsl"
    #endif
#endif

#define FRAGMENT
//#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    //if(fragment_cull()) discard;
    vec4 block_color = texture2DLod(colortex1, texcoord * RENDER_SCALE, 0);
    
    float d = texture2DLod(depthtex0, texcoord * RENDER_SCALE, 0).r;
    float linear_d = ld(d);
    
    #ifdef DISTANT_HORIZONS
        float d2 = texture2DLod(dhDepthTex0, texcoord * RENDER_SCALE, 0).r;
        float dh_d = ld_dh(d2);
    #endif

    #if !defined THE_END && !defined NETHER && ROUND_SUN < 2
        vec3 sun = draw_sun();
        #ifdef DISTANT_HORIZONS
            block_color.rgb += sun * step(0.9999, dh_d * d);
        #else
            block_color.rgb += sun * step(0.9999, d);
        #endif
    #endif

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    vec3 view_vector = vec3(1.0);

    #if AO == 1 || (V_CLOUDS > 0 && !defined UNKNOWN_DIM) || AURORA > 0
        #if AA_TYPE > 0 && !defined PS1_LIKE
            float dither = shifted_eclectic_r_dither(gl_FragCoord.xy);
        #else
            float dither = semiblue(gl_FragCoord.xy);
        #endif
    #endif

    #if ((V_CLOUDS > 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY) || AURORA > 0
        if(linear_d > 0.9999) {  // Only sky
            vec4 world_pos = gbufferModelViewInverse * gbufferProjectionInverse * (vec4(texcoord, 1.0, 1.0) * 2.0 - 1.0);
            view_vector = normalize(world_pos.xyz);

            vec4 fragpos = gbufferProjectionInverse * (vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z, 1.0) * 2.0 - 1.0);
            vec3 nfragpos = normalize(fragpos.xyz);
            float sun_influence = dot(nfragpos, sunPosition * 0.01);
            float normalized_sun_influence = smoothstep(-1.0, 1.0, sun_influence);
            float final_sun_factor = pow(normalized_sun_influence, day_blend_float(1.0, 0.0, 1.5));

            #ifdef THE_END
                float bright = dot(view_vector, vec3(0.0));
                bright = clamp((bright * 2.0) - 1.0, 0.0, 1.0);
                bright *= bright * bright * bright;
            #else
                float bright = final_sun_factor;
                bright *= day_blend_float(1.0, 1.0, 0.0);
            #endif

            #ifdef THE_END
                #ifdef END_CLOUDS
                    block_color.rgb = get_end_cloud(view_vector, block_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG);
                #endif
            #else
                block_color.rgb = get_cloud(view_vector, block_color.rgb, bright, dither, cameraPosition, CLOUD_STEPS_AVG, umbral, cloud_color, dark_cloud_color, dynamicValue);
            #endif
        }

    #else
        #if defined NETHER
            #if !defined DISTANT_HORIZONS
                if(linear_d > 0.9999) {  // Only sky
                    block_color = vec4(mix(fogColor * 0.25, vec3(0.5), 0.025), 1.0);
                }
            #endif
        #elif !defined NETHER && !defined THE_END
            if(linear_d > 0.9999 && isEyeInWater == 1) {  // Only sky and water
                vec4 screen_pos = vec4(gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), gl_FragCoord.z, 1.0);
                vec4 fragposition = gbufferProjectionInverse * (screen_pos * 2.0 - 1.0);

                vec4 world_pos = gbufferModelViewInverse * vec4(fragposition.xyz, 0.0);
                view_vector = normalize(world_pos.xyz);
            }
        #endif
    #endif

    #if AO == 1
        // AO distance attenuation
        #if defined NETHER
            if(NETHER_FOG_DISTANCE == 0) {
                linear_d = sqrt(linear_d);
            } else {
                float screen_distance = 2.0 * near * far / (far + near - (2.0 * d - 1.0) * (far - near));
                linear_d = screen_distance / NETHER_SIGHT;
            }
        #endif

        float ao_att = pow(clamp(linear_d * 1.6, 0.0, 1.0), mix(fog_density_coeff, 0.2, rainStrength));

        #ifdef DISTANT_HORIZONS
            if (d >= 1.0) {
                //float ao_attdh = pow(clamp(dh_d * 0.0, 0.0, 1.0), mix(fog_density_coeff, 0.2, rainStrength));
                
                float final_aodh = clamp(dh_dbao(dither), 0.0, 1.0);
                block_color.rgb *= final_aodh;
            }
        #endif

        float final_ao = clamp(mix(dbao(dither), 1.0, ao_att), 0.0, 1.0);
        block_color.rgb *= final_ao;
    #endif

    #if defined THE_END || defined NETHER
        #define NIGHT_CORRECTION 1.0
        #define COLOR_CORRECTION day_blend(vec3(1.0, 0.8, 1.0), vec3(1.0), vec3(1.0, 0.6, 1.0))
    #else
        #define NIGHT_CORRECTION day_blend_float(0.5, 0.75, 3.0)
        #define COLOR_CORRECTION day_blend(vec3(1.0, 0.8, 1.0), vec3(1.0), vec3(1.0, 0.6, 1.0))
    #endif

    float eye_brightness_scaled_val = (eye_bright_smooth.y * .8 + 48.0) * 0.004166666666666667;
    vec3 water_light_color_base = NIGHT_CORRECTION * saturate(WATER_COLOR, mix(1.0, 0.25, rainStrength)) * COLOR_CORRECTION * direct_light_strength;

    // Underwater sky
    if(isEyeInWater == 1) {
        if(linear_d > 0.9999) {
            block_color.rgb = mix(water_light_color_base * eye_brightness_scaled_val, block_color.rgb, max(clamp(view_vector.y - 0.1, 0.0, 1.0), rainStrength));
        }
    }

    block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));
    
    /* DRAWBUFFERS:124 */

    gl_FragData[0] = vec4(block_color.rgb, d);

    #ifdef BLOOM
        gl_FragData[1] = block_color;
    #endif

    #if SSR_TYPE > -1 || MATERIAL_GLOSS > 1
       gl_FragData[2] = block_color;
    #endif
}
#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;
uniform sampler2D noisetex;
varying vec3 worldPos;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float viewWidth;
uniform float viewHeight;

/* Ins / Outs */

varying vec2 texcoord;
varying float is_noshadow;
varying float visible_sky;
varying float is_water;

#if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
    varying vec3 vNormal;
    varying vec3 vBias;
#endif

#include "/lib/caustics.glsl"
#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

#define FRAGMENT
//#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    #ifndef CAUSTICS
        if (is_water > 0.98) {
            discard;
        }
    #endif

    if (is_noshadow > 0.98) {
        discard;
    }

    vec4 block_color;

    #if defined SHADOW_CASTING && SHADOW_LOCK > 0 && !defined NETHER
        float texelSize = float(SHADOW_LOCK);
        vec3 worldSpacePos = worldPos + cameraPosition;
        vec3 offsetPos = worldSpacePos + (vNormal * 0.02); 
        vec3 snappedWorld = floor(offsetPos * texelSize) / texelSize;
        snappedWorld += 0.5 / texelSize;
        vec3 finalWorldPos = (snappedWorld - cameraPosition) + vBias;
    #else
        vec3 finalWorldPos = worldPos;
    #endif

    #ifdef CAUSTICS
        if (is_water > 0.98) {
            #if WATER_TEXTURE == 0
                // Pixelated caustics
                vec3 wave_normal = normal_waves(finalWorldPos + cameraPosition.xyz);
                vec3 amplified_normal = wave_normal * 8.0 * CAUSTICS_INTENSITY;
                block_color.rgb = gray(amplified_normal) * vec3(1.0, 1.1, 1.1); 

                block_color.a = texture2D(tex, texcoord).a * 0.05 * amplified_normal.z * (CAUSTICS_INTENSITY * 0.5 + 0.5);
            #else
                block_color = texture2D(tex, texcoord);
                block_color.rgb *= fastpow3(block_color.rgb, 3.0);
                if (block_color.r < 0.325) {
                    block_color.a *= 0.6;
                }
                block_color.rgb *= vec3(0.95, 1.1, 1.1);
                block_color.a *= 0.45;
            #endif
            
        } else {
            block_color = texture2D(tex, texcoord);
        }
    #else
        block_color = texture2D(tex, texcoord);
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;
}

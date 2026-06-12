/* MakeUp - E-LITE shaders 5 - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;
uniform int moonPhase;
uniform vec3 fogColor;

#define NIGHT_BRIGHT_PHASE (NIGHT_BRIGHT + (NIGHT_BRIGHT_RANGE / 4.0) * abs(4.0 - moonPhase))

#define MID_SUNSET_COLOR HORIZON_SUNSET_COLOR
#define MID_DAY_COLOR HORIZON_DAY_COLOR
#define MID_NIGHT_COLOR HORIZON_NIGHT_COLOR

#if COLOR_SCHEME == 1  // New shoka
    #define OMNI_TINT 0.25
    #define LIGHT_SUNSET_COLOR vec3(1.0, 0.588, 0.3555)
    #define LIGHT_DAY_COLOR vec3(0.90, 0.84, 0.79)
    #define LIGHT_NIGHT_COLOR vec3(0.04786874, 0.05175001, 0.06112969) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.143, 0.24394118, 0.36450981)
    #define ZENITH_DAY_COLOR vec3(0.143, 0.24394118, 0.36450981)
    #define ZENITH_NIGHT_COLOR vec3(0.014, 0.019, 0.025) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.0, 0.648, 0.37824)
    #define HORIZON_DAY_COLOR vec3(0.65, 0.91, 1.3)
    #define HORIZON_NIGHT_COLOR vec3(0.0213, 0.0306, 0.0387) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.05, 0.1, 0.11)
#elif COLOR_SCHEME == 2  // LITE Realistic Plus (3 color layers)
    #define OMNI_TINT 0.5
    #define LIGHT_SUNSET_COLOR vec3(0.75, 0.375, 0.2025)
    #define LIGHT_DAY_COLOR vec3(1.1, 0.925, 0.85) * 1.1
    #define LIGHT_NIGHT_COLOR vec3(0.015, 0.02, 0.035) * NIGHT_BRIGHT_PHASE
    
    #if SIMPLE_SKY == 0 // E-LITE 5
        #define ZENITH_SUNSET_COLOR vec3(0.105, 0.135, 0.21)
        #define ZENITH_DAY_COLOR vec3(0.13, 0.31, 0.65)
        #define ZENITH_NIGHT_COLOR vec3(0.0075, 0.015, 0.0225) * NIGHT_BRIGHT_PHASE
        
        #define HORIZON_SUNSET_COLOR vec3(0.7, 0.35, 0.235)
        #define HORIZON_DAY_COLOR vec3(0.9, 0.92, 1.0)
        #define HORIZON_NIGHT_COLOR vec3(0.0, 0.01, 0.015) * NIGHT_BRIGHT_PHASE
    #else // LITE 4.1 Legacy
        #define ZENITH_SUNSET_COLOR vec3(0.3, 0.35, 0.45)
        #define ZENITH_DAY_COLOR vec3(0.45, 0.65, 1.0)
        #define ZENITH_NIGHT_COLOR vec3(0.01, 0.02, 0.03) * NIGHT_BRIGHT_PHASE

        #define HORIZON_SUNSET_COLOR vec3(0.6118, 0.4588, 0.4196)
        #define HORIZON_DAY_COLOR vec3(0.6, 0.8, 1.0)
        #define HORIZON_NIGHT_COLOR vec3(0.025, 0.03, 0.04) * NIGHT_BRIGHT_PHASE 
    #endif

    #undef  MID_SUNSET_COLOR // Avoiding error in Optifine, do not remove undef!
    #undef  MID_DAY_COLOR
    #undef  MID_NIGHT_COLOR

    #define MID_SUNSET_COLOR vec3(0.175, 0.225, 0.275)
    #define MID_DAY_COLOR vec3(0.25, 0.55, 0.9)
    #define MID_NIGHT_COLOR vec3(0.02, 0.025, 0.03) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.0, 0.15, 0.21)
#elif COLOR_SCHEME == 3  // LITE Realistic Legacy (3.3)
    #define OMNI_TINT 0.3
 
    #define LIGHT_SUNSET_COLOR vec3(0.8, 0.4, 0.2)
    #define LIGHT_DAY_COLOR vec3(0.9, 0.85, 0.8)
    #define LIGHT_NIGHT_COLOR vec3(0.07, 0.07, 0.08) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.3, 0.45, 0.625)
    #define ZENITH_DAY_COLOR vec3(0.25, 0.54, 0.93)
    #define ZENITH_NIGHT_COLOR vec3(0.015, 0.03, 0.045) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.0, 0.75, 0.7)
    #define HORIZON_DAY_COLOR vec3(0.6, 0.9, 1.0)
    #define HORIZON_NIGHT_COLOR vec3(0.02, 0.03, 0.04) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.1, 0.1, 0.15)
#elif COLOR_SCHEME == 4  // LITE Vanilla (Very hard too simulate Vanilla omg)
    #define OMNI_TINT 1.0

    #define LIGHT_SUNSET_COLOR vec3(0.66, 0.5, 0.5)
    #define LIGHT_DAY_COLOR vec3(0.9, 0.9, 1.0)
    #define LIGHT_NIGHT_COLOR vec3(0.075, 0.075, 0.1) * 0.3

    #define ZENITH_SUNSET_COLOR saturate(vec3(0.2, 0.4, 1.0), dayBF(0.6, 1.0, 0.2)) * 2.3 * dayBF(1.0, 1.0, 0.0) * dayBlend(vec3(1.0), vec3(1.0), vec3(1.2, 1.1, 0.8))
    #define ZENITH_DAY_COLOR vec3(0.29, 0.42, 1.0) * 2.3
    #define ZENITH_NIGHT_COLOR saturate(vec3(0.25, 0.4078, 1.0), 0.0) * skyColor * dayBF(1.0, 0.2, 1.0) * NIGHT_BRIGHT_PHASE * dayBlend(vec3(2.2, 1.8, 0.0), vec3(1.0), vec3(1.0))

    #define HORIZON_SUNSET_COLOR saturate(fogColor, dayBF(1.0, 1.0, 5.0)) * 2 * vec3(1.0, 0.8, 0.7) * dayBF(1.0, 1.0, 0.4)
    #define HORIZON_DAY_COLOR fogColor * 2.2 * vec3(0.75, 0.8, 1.0)
    #define HORIZON_NIGHT_COLOR saturate(fogColor, dayBF(0.0, 0.0, 0.6)) * dayBF(1.5, 0.35, 0.2) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.0314, 0.1373, 0.4784)
#elif COLOR_SCHEME == 5  // LITE Cursed
    #define OMNI_TINT 1.0

    #undef  MID_SUNSET_COLOR // Avoiding error in Optifine, do not remove undef!
    #undef  MID_DAY_COLOR
    #undef  MID_NIGHT_COLOR

    #define LIGHT_SUNSET_COLOR vec3(0.025)
    #define LIGHT_DAY_COLOR vec3(0.05)
    #define LIGHT_NIGHT_COLOR vec3(0.01) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.015)
    #define ZENITH_DAY_COLOR vec3(0.0706)
    #define ZENITH_NIGHT_COLOR vec3(0.01) * NIGHT_BRIGHT_PHASE

    #define MID_SUNSET_COLOR vec3(0.04)
    #define MID_DAY_COLOR vec3(0.0941, 0.0941, 0.0941)
    #define MID_NIGHT_COLOR vec3(0.005) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(0.0941, 0.0784, 0.0745)
    #define HORIZON_DAY_COLOR vec3(0.1255, 0.1255, 0.1255)
    #define HORIZON_NIGHT_COLOR vec3(0.01) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.0, 0.0, 0.0)
#elif COLOR_SCHEME == 6  // LITE Realistic simple (2 color layers)
    #define OMNI_TINT 0.5
    #define LIGHT_SUNSET_COLOR vec3(0.5, 0.225, 0.135)
    #define LIGHT_DAY_COLOR vec3(1.0, 0.8, 0.7)
    #define LIGHT_NIGHT_COLOR vec3(0.015, 0.02, 0.035) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.07, 0.0863, 0.1373)
    #define ZENITH_DAY_COLOR vec3(0.05, 0.4, 0.7)
    #define ZENITH_NIGHT_COLOR vec3(0.0075, 0.015, 0.0225) * NIGHT_BRIGHT_PHASE
    
    #define HORIZON_SUNSET_COLOR vec3(0.7, 0.35, 0.235)
    #define HORIZON_DAY_COLOR vec3(1.0)
    #define HORIZON_NIGHT_COLOR vec3(0.0, 0.01, 0.015) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.0, 0.105, 0.1375)
#elif COLOR_SCHEME == 7 // LITE Realistic (pollution) (ITS BACK OMG!!!)
    #define OMNI_TINT 0.25
    #define LIGHT_SUNSET_COLOR vec3(1.0, 0.5, 0.3)
    #define LIGHT_DAY_COLOR vec3(0.9, 0.75, 0.75)
    #define LIGHT_NIGHT_COLOR vec3(0.04, 0.05, 0.06) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.2, 0.3, 0.5)
    #define ZENITH_DAY_COLOR vec3(0.3, 0.5, 0.6)
    #define ZENITH_NIGHT_COLOR vec3(0.01, 0.02, 0.04) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.0, 0.5, 0.3)
    #define HORIZON_DAY_COLOR vec3(0.8, 0.7, 0.7)
    #define HORIZON_NIGHT_COLOR vec3(0.03, 0.03, 0.04) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.04, 0.06, 0.06)
#elif COLOR_SCHEME == 99 // Custom
    #define OMNI_TINT OMNI_TINT_CUSTOM
    #define LIGHT_SUNSET_COLOR vec3(LIGHT_SUNSET_COLOR_R, LIGHT_SUNSET_COLOR_G, LIGHT_SUNSET_COLOR_B)
    #define LIGHT_DAY_COLOR vec3(LIGHT_DAY_COLOR_R, LIGHT_DAY_COLOR_G, LIGHT_DAY_COLOR_B)
    #define LIGHT_NIGHT_COLOR vec3(LIGHT_NIGHT_COLOR_R, LIGHT_NIGHT_COLOR_G, LIGHT_NIGHT_COLOR_B) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(ZENITH_SUNSET_COLOR_R, ZENITH_SUNSET_COLOR_G, ZENITH_SUNSET_COLOR_B)
    #define ZENITH_DAY_COLOR vec3(ZENITH_DAY_COLOR_R, ZENITH_DAY_COLOR_G, ZENITH_DAY_COLOR_B)
    #define ZENITH_NIGHT_COLOR vec3(ZENITH_NIGHT_COLOR_R, ZENITH_NIGHT_COLOR_G, ZENITH_NIGHT_COLOR_B) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(HORIZON_SUNSET_COLOR_R, HORIZON_SUNSET_COLOR_G, HORIZON_SUNSET_COLOR_B)
    #define HORIZON_DAY_COLOR vec3(HORIZON_DAY_COLOR_R, HORIZON_DAY_COLOR_G, HORIZON_DAY_COLOR_B)
    #define HORIZON_NIGHT_COLOR vec3(HORIZON_NIGHT_COLOR_R, HORIZON_NIGHT_COLOR_G, HORIZON_NIGHT_COLOR_B) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(WATER_COLOR_R, WATER_COLOR_G, WATER_COLOR_B)
#endif

#define NV_COLOR vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B)

#include "/lib/day_blend.glsl"

// Fog parameter per hour
#if VOL_LIGHT == 1 || (VOL_LIGHT == 2 && defined SHADOW_CASTING) || defined UNKNOWN_DIM
    #define FOG_DENSITY 3.0
#endif
    
#define FOG_DAY 2.75
#define FOG_SUNSET 2.5
#define FOG_NIGHT 0.75


#include "/lib/color_conversion.glsl"

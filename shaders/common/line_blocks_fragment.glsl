/* Utility functions */
#include "/lib/config.glsl"

/* Ins / Outs & Uniforms */
varying vec4 tint_color;

#ifdef RGB_LINE
    varying vec3 pos;
#endif

uniform float viewWidth;
uniform float viewHeight;
uniform int renderStage;
uniform sampler2D gaux3;
uniform float frameTimeCounter;

#define FRAGMENT
//#include "/lib/downscale.glsl"

#ifdef RGB_LINE
    vec3 rgb_line(vec3 pos) {
        float speed = 0.5;
        float frequency = 0.2;
        float t = (frameTimeCounter * speed) + ((pos.x + pos.y + pos.z) * frequency);
        vec3 rgb = clamp(abs(mod(t * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
        
        return rgb * rgb;
    }
#endif

void main() {
    //if(fragment_cull()) discard;
    
    vec4 block_color = tint_color;
    float exposure = texture2D(gaux3, vec2(0.5)).r;

    #if defined IS_IRIS
        #if SELECTION_LINE > 1
            if (renderStage == MC_RENDER_STAGE_OUTLINE) {
                #ifdef RGB_LINE
                    vec3 color = rgb_line(pos);
                    block_color = vec4(color * 2.5, 1.0) / exposure;
                #else
                    block_color = vec4(2.0) / exposure;
                #endif
            }
        #elif SELECTION_LINE == 0
            if (renderStage == MC_RENDER_STAGE_OUTLINE) {
                block_color = vec4(0.0);
            }
        #endif
    #endif

    #include "/src/writebuffers.glsl"
}
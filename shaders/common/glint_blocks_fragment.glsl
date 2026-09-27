#include "/lib/config.glsl"

// == Uniforms
uniform sampler2D tex;

// == Varyings
varying vec2 texcoord;
varying vec4 tint_color;
varying float exposure;

// == Main function

void main() {
    // Toma el color puro del bloque
    vec4 block_color = texture2D(tex, texcoord) * tint_color * 1.5 / max(0.001, exposure);

    #include "/src/writebuffers.glsl"
}
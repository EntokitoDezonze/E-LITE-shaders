#include "/lib/config.glsl"

// == Uniforms
uniform sampler2D tex;

// == Varyings
varying vec2 texcoord;

// == Main function

void main() {
    // Toma el color puro del bloque
    vec4 block_color = texture2D(tex, texcoord);

    #include "/src/writebuffers.glsl"
}

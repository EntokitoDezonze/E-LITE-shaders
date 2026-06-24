/* MakeUp - E-LITE shaders 5 - tone_maps.glsl
Tonemap functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 custom_sigmoid(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(2.5)) + 1.0, vec3(0.4));

    return pow(color, vec3(1.15));
}

vec3 custom_sigmoid_alt(vec3 color) {
    color = 1.4 * color;
    color = color / pow(pow(color, vec3(2.5)) + 1.0, vec3(0.4));

    return pow(color, vec3(1.2));
}

vec3 Lottes(vec3 x, float expo) { // MakeUp legacy Lottes
    // Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
    // float a = 1.3;
    // float d = 0.997;
    // float midIn = 0.2;
    // float midOut = 0.24;

    float pow_a = pow(expo, 1.2961);
    float pow_b = pow(expo, 1.3);
    float product_a = (pow_a * 0.24) - 0.02980411421941949;

    float b =
        (-0.12340677254400192 + pow_b * 0.24) /
        product_a;
    float c =
        (pow_a * 0.12340677254400192 - pow_b * 0.02980411421941949) /
        product_a;

    return pow(x, vec3(1.3)) / (pow(x, vec3(1.2961)) * b + c);
}

// Based on: https://github.com/dmnsgn/glsl-tone-map/blob/main/aces.glsl
// MIT license.

vec3 ACESFilm(vec3 x, float outputWhitePoint) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;

    vec3 mapped = (x * (a * x + b)) / (x * (c * x + d) + e);
    mapped = mapped * (1.0 + mapped / (outputWhitePoint * outputWhitePoint));
    
    #ifdef HDR
        return pow(mapped, vec3(1.5));
    #else
        return clamp(mapped, 0.0, 1.0);
    #endif
}

// Based on: https://github.com/dmnsgn/glsl-tone-map/blob/main/uchimura.glsl
// MIT license.

// Uchimura 2017, "HDR theory and practice"
// Math: https://www.desmos.com/calculator/gslcdxvipg
// Source: https://www.slideshare.net/nikuque/hdr-theory-and-practicce-jp
vec3 uchimura(vec3 x, float P, float a, float m, float l, float c, float b) {
    float l0 = ((P - m) * l) / a;
    float S0 = m + l0;
    float S1 = m + a * l0;
    float CP = (a * P + b) / (l0 * P + m);

    vec3 w0 = vec3(1.0 - smoothstep(0.0, m, x));
    vec3 w2 = vec3(step(m + l0, x));
    vec3 w1 = vec3(1.0 - w0 - w2);

    vec3 T = vec3(m * pow(x / m, vec3(c)) + b);
    vec3 L = vec3(m + a * (x - m));
    vec3 S = vec3(P - (P - S1) * exp(-CP * (x - S0)));

    return T * w0 + L * w1 + S * w2;
}

vec3 uchimura_tm(vec3 color) {
    float P = 1.0;
    float a = 1.0;
    float m = 0.22;
    float l = 0.4;
    float c = 1.25;
    float b = 0.0;
    color *= 1.25;

    return uchimura(color, P, a, m, l, c, b);
}
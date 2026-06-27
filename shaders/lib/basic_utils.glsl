/* MakeUp - E-LITE shaders 5 - basic_utils.glsl
Misc utilities.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float fastpow(float base, float p) {
    int exp = int(p);
    float res = 1.0;
    float b = base;

    /* fastpow - E-LITE 5
    The power of example is 6.
    | STEP | MASK  | BINARY (6) | MATCH? | ACTION
    | 1    | & 1   | 110 & 001  | NO     | skip
    | 2    | & 2   | 110 & 010  | YES    | 1.0 *= b
    | 3    | & 4   | 110 & 100  | YES    | 1.0 *= b^4

    b^2 * b^4 = b^6
    */

    if ((exp & 1) != 0) res *= b; b *= b;
    if ((exp & 2) != 0) res *= b; b *= b;
    if ((exp & 4) != 0) res *= b; b *= b;
    if ((exp & 8) != 0) res *= b; b *= b;
    if ((exp & 16) != 0) res *= b; b *= b;
    if ((exp & 32) != 0) res *= b;

    float f = fract(p);
    res *= mix(1.0, sqrt(base), step(0.249, f));

    return res;
}

vec2 fastpow2(vec2 b, float p) {
    return vec2(fastpow(b.x, p), fastpow(b.y, p));
}

vec3 fastpow3(vec3 b, float p) {
    return vec3(fastpow(b.x, p), fastpow(b.y, p), fastpow(b.z, p));
}

vec4 fastpow4(vec4 b, float p) {
    return vec4(fastpow(b.x, p), fastpow(b.y, p), fastpow(b.z, p), fastpow(b.w, p));
}

float squarePow(float x) {
    return x * x;
}

float cubePow(float x) {
    return x * x * x;
}

float fourthPow(float x) {
    float temp2 = x * x;
    return temp2 * temp2;
}

float fifthPow(float x) {
    float temp2 = x * x;
    return temp2 * temp2 * x;
}

float sixthPow(float x) {
    float temp2 = x * x;
    return temp2 * temp2 * temp2;
}

vec3 SquarePowVec3(vec3 x) {
    return x * x;
}

vec3 cubePowVec3(vec3 x) {
    return x * x * x;
}

vec3 fourthPowVec3(vec3 x) {
    vec3 temp2 = x * x;
    return temp2 * temp2;
}

vec3 fifthPowVec3(vec3 x) {
    vec3 temp2 = x * x;
    return temp2 * temp2 * x;
}

vec3 sixthPowVec3(vec3 x) {
    vec3 temp2 = x * x;
    return temp2 * temp2 * temp2;
}

vec4 squarePowVec4(vec4 x) {
    return x * x;
}

vec4 cubePowVec4(vec4 x) {
    return x * x * x;
}

vec4 fourthPowVec4(vec4 x) {
    return x * x * x * x;
}

vec4 fifthPowVec4(vec4 x) {
    vec4 temp2 = x * x;
    return temp2 * temp2 * x;
}

vec4 sixthPowVec4(vec4 x) {
    vec4 temp2 = x * x;
    return temp2 * temp2 * temp2;
}

// == arccos Approximation
// Source: https://www.forwardscattering.org/post/66
// Code by Nicholas Chapman
float fastApproxACos(float x){
	if(x < 0.0) {
		return 3.14159265 - ((x * 0.124605335 + 0.1570634) * (0.99418175 + x) + sqrt(2.0 + 2.0 * x));	
    } else {
		return (x * -0.124605335 + 0.1570634) * (0.99418175 - x) + sqrt(2.0 - 2.0 * x);
    }
}

// arctan approximation
// Source: https://iquilezles.org/maths/arctan/
// By Inigo Quilez
float fastAtan(float x) {
    float x2 = x * x;
    return (9.8696044 * x) / (4.0 + sqrt(34.0 + 39.4784176 * x2));
}

float fastAtan2(float y, float x) {
    float absX = abs(x);
    float absY = abs(y); // Quadrant
    bool swap = absY > absX;
    float n = swap ? absX / absY : absY / absX;
    float angle = fastAtan(n);

    if (swap) angle = 1.5707963 - angle; // PI/2 - angle
    if (x < 0.0) angle = 3.1415926 - angle;
    return (y < 0.0) ? -angle : angle;
}

// == Sinus and Cosinus approximation
// Source: https://gist.github.com/publik-void/067f7f2fef32dbe5c27d6e215f824c91
// Based on Horner's method.

// 11th degree - medium precision
float fastSin11(float x) {
    float x2 = x * x;
    return x * (0.9999999999788490 + x2 * (-0.1666666660882607 + x2 * (0.0083333307205577 + x2 * (-0.0001984083282326 + x2 * (0.0000027523971075 + x2 * (-0.0000000238683465))))));
}

float fastCos11(float x) {
    return fastSin11(x + 1.570796);
}

// 17th degree - high precision
float fastSin17(float x) {
    float x2 = x * x;
    return x * (1.0 + x2 * (-0.1666666666662705 + x2 * (0.0083333333314545 + x2 * (-0.0001984126937666 + x2 * (0.0000027557303035 + x2 * (-0.0000000250507567 + x2 * (0.0000000001592671 + x2 * (-0.0000000000006766 + x2 * 0.0000000000000018))))))));
}

float fastCos17(float x) {
    return fastSin17(x + 1.5707963267948966);
}


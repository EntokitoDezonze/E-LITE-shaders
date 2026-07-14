/* MakeUp - E-LITE shaders 5 - shadow_vertex.glsl
Vertex shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

vec3 get_shadow_pos(vec3 shadow_pos) {
    shadow_pos = mat3(shadowModelView) * shadow_pos + shadowModelView[3].xyz;
    shadow_pos = diagonal3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

    float p = 4.0;
    float dist = pow(pow(abs(shadow_pos.x), p) + pow(abs(shadow_pos.y), p), 1.0 / p);

    float falloff = 1.0 / (1.0 + dist * 0.1);
    float distortion = mix(1.0, dist, SHADOW_DIST * falloff);
    
    shadow_pos.xy /= min(distortion, 0.75);
    shadow_pos.z *= 0.2;
    return shadow_pos * 0.5 + 0.5;
}

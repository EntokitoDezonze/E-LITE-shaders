/* ____    __   ______________
  / __/___/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/  
/___/   /____/___/ /_/ /___/  
                                                      
E-LITE shaders 5 - render_aux.glsl
Render auxiliary calculations. - Cálculos auxiliares de renderização.
*/

float hash21(vec2 p) {
    float n = p.x * 12.9898 + p.y * 78.233;
    n = fract(n * 0.0031); 
    n *= n + 33.33;        
    n *= n + n;            
    return fract(n);
}

float noise2D_grid(vec2 p) {
    vec2 i = floor(p); 
    return hash21(i);
}

/*
float noise2D_grid_inclined(vec2 p) {
    float shear_factor = 0.5; 
    vec2 p_inclined = vec2(p.x + p.y * shear_factor, p.y);
    vec2 i = floor(p_inclined); 
    
    return hash21(i);
}
Uncomment when needed. */

vec3 reconstructWorldPosition(float depth, vec2 resolution) {
    vec2 ndc_xy = (gl_FragCoord.xy / RENDER_SCALE / resolution) * 2.0 - 1.0;
    vec4 frag_view_space = gbufferProjectionInverse * vec4(ndc_xy, depth, 1.0);
    frag_view_space.xyz /= frag_view_space.w; 
    return (gbufferModelViewInverse * frag_view_space).xyz - gbufferModelViewInverse[3].xyz;
} // Fixed sway with view bobbing.

vec2 cubic_uv(vec3 direction) {
    vec3 abs_dir = abs(direction);
    float max_c = max(max(abs_dir.x, abs_dir.y), abs_dir.z);
    
    vec3 mask = step(max_c, abs_dir);

    vec2 uv = (mask.x * direction.yz + mask.y * direction.xz + mask.z * direction.xy) / max_c;
    return uv * 0.5 + 0.5;
}
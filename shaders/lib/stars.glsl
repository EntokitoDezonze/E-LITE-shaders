/* ____    __   ______________
  / __/___/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/  
/___/   /____/___/ /_/ /___/  
                                                      
E-LITE shaders 5 - stars.glsl
Stars render fixed in world space. - Renderização de estrelas fixas no espaço do mundo. 

Based on https://www.shadertoy.com/view/Md2SR3
License:  https://creativecommons.org/licenses/by-nc-sa/3.0/
Modified.
*/

float NoisyStarField(in vec2 p_grid_coord, float fThreshhold) {
    #ifndef THE_END
        if(dayBF(0.1, 0.0, 1.0) < 0.01) return 0.0; // <- Discard stars during daytime on overworld
    #endif
    
    float StarVal = noise2D_grid(p_grid_coord);

    float isStar = step(fThreshhold, StarVal);
    StarVal = fastpow((StarVal - fThreshhold) / (1.0 - fThreshhold), 10.0);
    return isStar * step(0.3, StarVal) * clamp(StarVal, 0.1, 1.0);
}

vec3 stars() {
    #if (STAR_SLIDER == 2 && !defined THE_END && !defined NETHER) || (defined END_STARS && defined THE_END)
        
        vec2 resolution = vec2(viewWidth, viewHeight);
        
        vec3 dir = reconstructWorldPosition(gl_FragCoord.z, resolution); // <- Expensive function but necessary, prepare vertex calculates the position incorrectly.

    #ifndef THE_END
        if (sunPathRotation != 0.0) {
            float rad = sunPathRotation * 0.0174532925;
            float tc = cos(rad);
            float ts = sin(-rad);

            float dy = dir.y * tc - dir.z * ts;
            dir.z = dir.y * ts + dir.z * tc;
            dir.y = dy;

            float angle = sunAngle * 6.4 - 0.14;
            mat2 rot = mat2(sin(angle), -cos(angle), cos(angle), sin(angle));
            dir.xz *= rot;
        } else {
            dir.yz = vec2(dir.z, -dir.y);
            
            float angle = sunAngle * 6.28318530718;
            mat2 rot = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
            dir.xz *= rot;
        }
    #endif
    // This calc makes the stars to follow the moon.

        vec2 p_spherical = cubic_uv(dir); 
        float star_scale = 600.0;
        vec2 p_continuous = p_spherical * star_scale;
        float star_density_threshold = 0.99 - (0.015 * STARS_COVERAGE * STARS_COVERAGE);
        float star_brightness = STARS_BRIGHTNESS * 0.75;
        float star_intensity = NoisyStarField(p_continuous, star_density_threshold); // <- Draw stars
        vec3 final_color = vec3(star_intensity);

        #ifndef THE_END
            final_color *= dayBFlgcy(0.1, 0.0, 0.9) * (star_brightness * 0.5 + 0.5) * (1 -rainStrength);
        #endif

        #ifdef THE_END
            final_color *= vec3(0.75, 0.5, 1.0) * 2 * star_brightness;
        #endif

    #else
        vec3 final_color = vec3(0.0);
    #endif
    
    #if defined THE_END && !defined NETHER
        return (final_color * final_color * final_color);
    #else
        return final_color * final_color * final_color * 0.8;
    #endif
}
/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/  
/___/   /____/___/ /_/ /___/  
                      
E-LITE shaders 5 - current_sky_color.glsl #include "/src/current_sky_color.glsl"
Sky color calculation. - Cálculo da cor do céu. */

float lightning = step(0.001, lightningBoltPosition.w);

float sun_influence = dot(nfragpos, sunPosition * 0.01);
float sun_ss = smoothstep(-1.0, 1.0, sun_influence);

float final_sun_factor = fastpow(sun_ss, dayBFlgcy(1.0, 1.0, 2.0));
float final_sun_factor2 = fastpow(sun_ss, dayBF(1.5, 0.0, 10.0));

#if COLOR_SCHEME == 4
    float final_sun_factor3 = fastpow(sun_ss, dayBF(1.0, 0.0, 1.75));
    vec3 current_low_sky_color = mix(mid_sky_color * dayBF(1.0, 1.0, 0.75), low_sky_color, final_sun_factor3);
    vec3 current_mid_sky_color = mid_sky_color;
    vec3 current_hi_sky_color = hi_sky_color;
#elif COLOR_SCHEME == 2 || COLOR_SCHEME == 5
    vec3 current_low_sky_color = mix(pure_low_sky_color * dayBF(0.1, 0.0, dayBF(0.1, 0.0, 0.0)) + pure_mid_sky_color * dayBF(mix(dayBF(3.5, 2.5, 1.0), 2.0, rainStrength), mix(1.0, 0.25, rainStrength), mix(dayBF(0.0, 0.0, 2.0), 2.0, rainStrength)) * 0.5 + low_sky_color * dayBF(0.1, 1.0, 0.05), low_sky_color * dayBFlgcy(2.0, 1.5, mix(1.25, 3.0, rainStrength)), final_sun_factor);
    vec3 current_mid_sky_color = mix((pure_hi_sky_color + pure_mid_sky_color) * dayBFlgcy(dayBF(0.5, 0.4, 0.2), mix(0.7, 0.2, rainStrength), mix(dayBF(0.5, 0.0, 0.4), 0.4, rainStrength)) + (mid_sky_color * 2.0 * lightning), mid_sky_color * dayBF(1.1, 1.0, 0.75) + (mid_sky_color * 2.0 * lightning), final_sun_factor2);
    vec3 current_hi_sky_color = mix(hi_sky_color * dayBF(dayBF(0.8, 0.8, 0.5), 1.0, 1.0) + (hi_sky_color * lightning), hi_sky_color + (hi_sky_color * lightning), final_sun_factor);
#else
    vec3 current_low_sky_color = low_sky_color;
    vec3 current_mid_sky_color = low_sky_color;
    vec3 current_hi_sky_color = hi_sky_color;
#endif
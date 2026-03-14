/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/  
/____/___/ /_/ /___/  
                      
E-LITE shaders 5 - current_sky_color.glsl #include "/src/current_sky_color.glsl"
Sky color calculation. - Cálculo da cor do céu. */

float lightning = step(0.001, lightningBoltPosition.w);

float sun_influence = dot(nfragpos, sunPosition * 0.01);
float sun_ss = smoothstep(-1.0, 1.0, sun_influence);

float final_sun_factor = pow(sun_ss, day_blend_float_lgcy(1.0, 1.0, 2.0));
float final_sun_factor2 = pow(sun_ss, day_blend_float(1.5, 0.0, 10.0));

#if COLOR_SCHEME == 4
    float final_sun_factor3 = pow(sun_ss, day_blend_float(1.0, 0.0, 1.75));
    vec3 current_low_sky_color = mix(mid_sky_color * day_blend_float(1.0, 1.0, 0.75), low_sky_color, final_sun_factor3);
    vec3 current_mid_sky_color = mid_sky_color;
    vec3 current_hi_sky_color = hi_sky_color;
#elif COLOR_SCHEME == 2 || COLOR_SCHEME == 5
    vec3 current_low_sky_color = mix(pure_mid_sky_color * day_blend_float_lgcy(4.5, 1.0, 2.0) * 0.5 + low_sky_color * day_blend_float(0.1, 1.0, 0.05), low_sky_color * day_blend_float_lgcy(2.0, 1.5, 1.5), final_sun_factor);
    vec3 current_mid_sky_color = mix((pure_hi_sky_color + pure_mid_sky_color) * day_blend_float_lgcy(0.4, 0.7, 0.4) + (mid_sky_color * lightning), mid_sky_color * day_blend_float(1.0, 1.0, 0.75) + (2.0 * lightning), final_sun_factor2);
    vec3 current_hi_sky_color = mix(hi_sky_color * day_blend_float(0.8, 1.0, 1.0) + (hi_sky_color * lightning), hi_sky_color * (1.0 + lightning), final_sun_factor);
#else
    vec3 current_low_sky_color = low_sky_color;
    vec3 current_mid_sky_color = low_sky_color;
    vec3 current_hi_sky_color = hi_sky_color;
#endif
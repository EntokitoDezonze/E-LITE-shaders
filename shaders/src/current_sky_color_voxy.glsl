/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/  
/____/___/ /_/ /___/  
                      
E-LITE shaders 5 - current_sky_color.glsl #include "/src/current_sky_color.glsl"
Sky color calculation. - Cálculo da cor do céu. */

float lightning = step(0.001, lightningBoltPosition.w);

float sun_influence = dot(viewPositionNormalized, sunPosition * 0.01);
float sun_ss = smoothstep(-1.0, 1.0, sun_influence);

float final_sun_factor = pow(sun_ss, dayBlendFloatVoxy(1.0, 1.0, 2.0, dayMixerV, nightMixerV, dayMomentV));
float final_sun_factor2 = pow(sun_ss, dayBlendFloatVoxyN(1.5, 0.0, 10.0, dayMixerV, nightMixerV, dayMomentV));

#if COLOR_SCHEME == 4
    float final_sun_factor3 = pow(sun_ss, dayBlendFloatVoxyN(1.0, 0.0, 1.75, dayMixerV, nightMixerV, dayMomentV));
    vec3 current_low_sky_color = mix(mid_sky_color * dayBlendFloatVoxyN(1.0, 1.0, 0.75, dayMixerV, nightMixerV, dayMomentV), horizonSkyColor, final_sun_factor3);
    vec3 current_mid_sky_color = mid_sky_color;
    vec3 current_hi_sky_color = zenithSkyColor;
#elif COLOR_SCHEME == 2 || COLOR_SCHEME == 5
    vec3 current_low_sky_color = mix(
        pure_mid_sky_color * dayBlendFloatVoxy(mix(4.5, 1.333, rainStrength), mix(2.75, 0.5, rainStrength), mix(3.0, 1.5, rainStrength), dayMixerV, nightMixerV, dayMomentV) * 0.5 
        + horizonSkyColor * dayBlendFloatVoxyN(0.1, 0.666, 0.05, dayMixerV, nightMixerV, dayMomentV),
        saturate(horizonSkyColor, dayBlendFloatVoxyN(1.0, 1.0, 0.75, dayMixerV, nightMixerV, dayMomentV)) * dayBlendFloatVoxy(1.8, 1.5, 2.5, dayMixerV, nightMixerV, dayMomentV), 
        final_sun_factor
    );
  //  vec3 current_mid_sky_color = mix((pure_hi_sky_color + pure_mid_sky_color) * dayBlendFloatVoxyN(0.4, 0.7, mix(0.5, 0.4, rainStrength), dayMixerV, nightMixerV, dayMomentV) + (mid_sky_color * 2.0 * lightning), mid_sky_color * dayBlendFloatVoxyN(1.0, 1.0, 0.75, dayMixerV, nightMixerV, dayMomentV) + (mid_sky_color * 2.0 * lightning), final_sun_factor2);
    vec3 current_hi_sky_color = zenithSkyColor * dayBlendFloatVoxy(mix(1.0, 1.0, rainStrength), mix(1.0, 0.25, rainStrength), mix(mix(1.0, 0.8, final_sun_factor), 1.5, rainStrength), dayMixerV, nightMixerV, dayMomentV);
#else
    vec3 current_low_sky_color = horizonSkyColor;
   // vec3 current_mid_sky_color = horizonSkyColor;
    vec3 current_hi_sky_color = zenithSkyColor;
#endif
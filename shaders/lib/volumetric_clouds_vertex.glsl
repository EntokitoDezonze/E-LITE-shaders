#if MC_VERSION >= 11300
    umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .25;
#else
    umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .45;
#endif

#if COLOR_SCHEME == 5
    umbral *= 0.75;
#endif

umbral *= CLOUD_DENSITY;

bool check = (lightningBoltPosition.w > 0.001);
float lightning = float(check);

vec3 antiRed = dayBlend(vec3(1.0), vec3(1.0, 1.0, 1.5), vec3(1.0)); // Avoid red color in transition during tick 0 to ~3000

#if CLOUD_VOL_STYLE == 0
    dark_cloud_color = dayBlend(
        ZENITH_SUNSET_COLOR,
        saturate(ZENITH_DAY_COLOR, 1.25),
        ZENITH_NIGHT_COLOR
    );
    
    vec3 cloud_color_aux = mix(
        dayBlend(
            saturate(LIGHT_SUNSET_COLOR, dayBF(0.9, 0.0, 0.5)) * dayBF(0.55, 0.0, 0.25),
            saturate(LIGHT_DAY_COLOR * dayBF(0.5, 1.0, 0.0), 0.0),
            LIGHT_NIGHT_COLOR * 1.333
        ),
        ZENITH_SKY_RAIN_COLOR * dayBF(1.0, 0.6, 1.0) * gray(dark_cloud_color),
        rainStrength
    );

    dark_cloud_color = mix(
        dark_cloud_color,
        ZENITH_SKY_RAIN_COLOR * color_average(dark_cloud_color * dayBF(1.15, 0.65, 1.25)),
        rainStrength
    );
#else
    dark_cloud_color = dayBlend(
        ZENITH_SUNSET_COLOR * 0.75,
        #if COLOR_SCHEME == 4
            ZENITH_DAY_COLOR * 0.5,
        #else
            ZENITH_DAY_COLOR * 1.5,
        #endif
        ZENITH_NIGHT_COLOR * 0.5
    );
    
    vec3 cloud_color_aux = mix(
        dayBlend(
            saturate(LIGHT_SUNSET_COLOR, 0.75) * dayBF(0.6, 0.5, 0.15),
            LIGHT_DAY_COLOR * 0.9,
            saturate(LIGHT_NIGHT_COLOR, 0.5) * 1.5
        ),
        ZENITH_SKY_RAIN_COLOR * saturate(dark_cloud_color, 0.2) * dayBF(1.0, 0.3, dayBF(-1.0, 1.0, 3.0)),
        rainStrength
    );

    dark_cloud_color = mix(
        dark_cloud_color,
        ZENITH_SKY_RAIN_COLOR * color_average(dark_cloud_color * dayBFlgcy(1.5, 0.4, 1.25)),
        rainStrength
    );
#endif



cloud_color = mix(
    clamp(mix(gray(cloud_color_aux), cloud_color_aux, 0.5) * vec3(1.5), 0.0, 1.4),
    dayBlend(
        MID_SUNSET_COLOR * dayBF(0.5, 0.5, 0.1) * antiRed,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR
    ),
    0.3
);

cloud_color = mix(cloud_color, (HORIZON_SKY_RAIN_COLOR + (HORIZON_SKY_RAIN_COLOR * lightning)) * luma(cloud_color_aux) * 5.0, rainStrength);

#if CLOUD_VOL_STYLE == 0
    dark_cloud_color = mix(dark_cloud_color, cloud_color, clamp(0.25 / (CLOUD_DENSITY), -1.0, 0.5));
#else
    dark_cloud_color = mix(dark_cloud_color, cloud_color, 0.3);
#endif

dark_cloud_color = mix(
    dark_cloud_color,
    dayBlend(
        cloud_color_aux,
        dark_cloud_color,
        dark_cloud_color
    ),
    0.4
);

#if COLOR_SCHEME == 4
    cloud_color *= mix(1.75, 0.5, rainStrength);
    dark_cloud_color *= mix(1.75, 0.5, rainStrength);
#endif
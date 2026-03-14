/* ____    __   ______________
  / __/___/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/  
/___/   /____/___/ /_/ /___/  
                                                      
E-LITE shaders 5 - seasons.glsl
Dynamic seasons. - Estações dinâmicas.
*/

#ifdef SEASONS
    #include "/lib/oscilator_utils.glsl"

    const vec3 SUMMER_COLOR = vec3(1.0);
    const vec3 AUTUMN_COLOR = vec3(1.0, 0.8, 0.7) * 1.05;
    const vec3 WINTER_COLOR = vec3(0.9, 0.775, 1.0) * 1.15;
    const vec3 SPRING_COLOR = vec3(0.95, 1.05, 1.0);    


    vec3 getSeasonColor(float time) {
        float daysPassed = time * 0.0416666; // time / 24.0
        float yearCycle = mod(daysPassed / SEASON_LENGTH, 4.0);
        
        float mix1 = smoothstep(0.8, 1.0, yearCycle) * (1.0 - step(2.0, yearCycle));
        float mix2 = smoothstep(1.8, 2.0, yearCycle) * (1.0 - step(3.0, yearCycle));
        float mix3 = smoothstep(2.8, 3.0, yearCycle);
        float mix0 = (1.0 - smoothstep(0.0, 0.2, yearCycle)) + step(3.8, yearCycle);

        vec3 color = SUMMER_COLOR;
        color = mix(color, AUTUMN_COLOR, smoothstep(0.9, 1.0, yearCycle));
        color = mix(color, WINTER_COLOR, smoothstep(1.9, 2.0, yearCycle));
        color = mix(color, SPRING_COLOR, smoothstep(2.9, 3.0, yearCycle));
        color = mix(color, SUMMER_COLOR, smoothstep(3.9, 4.0, yearCycle));

        return color;
    }

    vec4 seasonColor = vec4(getSeasonColor(TotalWorldTime), 1.0);
#else
    vec4 seasonColor = vec4(1.0);
#endif
/* ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/  
/___/   /____/___/ /_/ /___/
                                    
E-LITE shaders 5 - emissive_materials.glsl #include "/lib/emissive_materials.glsl"
Emissive properties for ores, some materials, particles and entities. - Propriedades emissivas para minérios, alguns materiais, partículas e entidades. */

vec3 emissive_color = vec3(1.0);

#if (defined EMISSIVE_ORE || defined EMISSIVE_MATERIAL)
    float correct_light = 1.0;
    float correct_light_ore = 1.0;  
    vec3 color = pure_block_color.rgb;
    vec3 sqrt_color = sqrt(pure_block_color.rgb);
    float luma_color = luma(sqrt(pure_block_color.rgb)); 
    float luminance = luma(pure_block_color.rgb);
    // * luma_color = pow(x, 1.5);
    // * luma(color) = pow(x, 2.0);

    if (luma(color) < 0.05 && ore_type == 0 && emitter_type == 0) {
    } else 
    
    if (ore_type > 0 || emitter_type > 0) {
        
        float saturation = 0.0;
        correct_light_ore = clamp(luma(1.0 - real_light), 0.5, 1.0);
        correct_light = clamp(luma(2.0 - real_light + gloss), 0.5, 1.0) - luma(gloss);
        
        float min_color = min(min(color.r, color.g), color.b);
        float max_color = max(max(color.r, color.g), color.b);
        saturation = (max_color - min_color) / (max_color + 0.0001);


    #if defined EMISSIVE_ORE && defined GBUFFER_TERRAIN
        float factor_gold    = isType(ore_type, 1);
        float factor_diamond = isType(ore_type, 2);
        float factor_iron    = isType(ore_type, 3);
        float factor_emerald = isType(ore_type, 4);
        float factor_redstone = isType(ore_type, 5);
        float factor_quartz  = isType(ore_type, 6);
        float factor_lapis   = isType(ore_type, 7);
        float factor_copper  = isType(ore_type, 8);
        
        // GOLD (ore_type == 1)
        vec3 target_color_gold = vec3(1.0, 1.0, 0.0);
        float match_cond_1_gold = getColor(color, target_color_gold, 1.0) * checkSat(saturation, 0.1, 1.0) * checkLum(luminance, 0.34, 1.0);
        float match_cond_2_gold = float(all(greaterThan(color, vec3(0.9))));
        float gold_match = clamp(match_cond_1_gold + match_cond_2_gold, 0.0, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 8.0 * luma_color * vec3(1.0, 0.66, 0.66) * correct_light_ore, gold_match * factor_gold);

        // DIAMOND (ore_type == 2)
        vec3 target_color_dark_diamond = vec3(0.0, 1.0, 1.0);
        vec3 target_color_light_diamond = vec3(1.0, 1.0, 1.0);
        float match_cond_1_diamond = getColor(color, target_color_dark_diamond, 0.49);
        float match_cond_2_diamond = getColor(color, target_color_light_diamond, 0.09);
        float diamond_match = clamp(match_cond_1_diamond + match_cond_2_diamond, 0.0, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 9.5 * luma(color) * luma_color * correct_light_ore, diamond_match * factor_diamond);

        // IRON (ore_type == 3)
        vec3 target_color_iron = vec3(0.816, 0.667, 0.557);
        float iron_match = getColor(color, target_color_iron, 1.0) * checkSat(saturation, 0.1, 1.0) * checkLum(luminance, 0.2, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 10.0 * luma(color) * vec3(1.0, 0.6, 0.5) * correct_light_ore, iron_match * factor_iron);

        // EMERALD (ore_type == 4)
        vec3 target_color_dark_emerald = vec3(0.0, 0.4, 0.0);
        vec3 target_color_light_emerald = vec3(0.6, 1.0, 0.6);
        float match_cond_1_emerald = getColor(color, target_color_dark_emerald, 0.09);
        float match_cond_2_emerald = getColor(color, target_color_light_emerald, 0.49);
        float emerald_match = clamp(match_cond_1_emerald + match_cond_2_emerald, 0.0, 1.0);
        emerald_match *= checkSat(saturation, 0.14, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 10.0 * luma_color * vec3(0.25, 0.6, 0.2) * correct_light_ore, emerald_match * factor_emerald);

        // REDSTONE (ore_type == 5)
        vec3 target_color_dark_redstone = vec3(1.0, 0.0, 0.0);
        vec3 target_color_light_redstone = vec3(1.0, 0.5, 0.5);
        float match_cond_1_redstone = getColor(color, target_color_dark_redstone, 0.49);
        float match_cond_2_redstone = getColor(color, target_color_light_redstone, 0.49);
        float redstone_match = clamp(match_cond_1_redstone + match_cond_2_redstone, 0.0, 1.0);
        redstone_match *= checkSat(saturation, 0.35, 1.0) * checkLum(luminance, 0.01, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 10.0 * vec3(1.0, 0.5, 0.5) * color * correct_light_ore, redstone_match * factor_redstone);

        // QUARTZ (ore_type == 6)
        vec3 target_color_dark_quartz = vec3(0.443, 0.325, 0.224);
        vec3 target_color_light_quartz = vec3(1.0);
        float match_cond_1_quartz = getColor(color, target_color_dark_quartz, 0.49);
        float match_cond_2_quartz = getColor(color, target_color_light_quartz, 0.5625);
        float quartz_match = clamp(match_cond_1_quartz + match_cond_2_quartz, 0.0, 1.0);
        quartz_match *= checkLum(luminance, 0.45, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 12.0 * luma(color) * vec3(0.6, 0.5, 0.5) * correct_light_ore, quartz_match * factor_quartz);

        // LAPIS (ore_type == 7)
        vec3 target_color_lapis = vec3(0.0, 0.0, 1.0);
        float lapis_match = getColor(color, target_color_lapis, 0.5625) * checkSat(saturation, 0.1, 1.0) * checkLum(luminance, 0.1, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 20.0 * luma(color) * vec3(0.5, 0.5, 1.0) * correct_light_ore, lapis_match * factor_lapis);

        // COPPER (ore_type == 8)
        vec3 target_color_dark_copper = vec3(0.847,0.486,0.282);
        vec3 target_color_light_copper = vec3(0.341,0.737,0.616);
        float base_match_copper = checkSat(saturation, 0.3, 1.0) * checkLum(luminance, 0.1, 1.0);
        
        float match_dark_copper = getColor(color, target_color_dark_copper, 0.3) * base_match_copper;
        float match_light_copper = getColor(color, target_color_light_copper, 0.25) * base_match_copper;
        
        vec3 factor_dark_luma = 15.0 * luma(color) * vec3(1.0, 0.7, 0.5) * correct_light_ore;
        vec3 factor_light_luma = 10.0 * luma(color)* vec3(0.5, 1.0, 0.7) * correct_light_ore;
        
        vec3 final_copper_emissive = mix(vec3(1.0), factor_dark_luma, match_dark_copper);
        final_copper_emissive = mix(final_copper_emissive, factor_light_luma, match_light_copper);
        
        float copper_total_match = clamp(match_dark_copper + match_light_copper, 0.0, 1.0);
        
        emissive_color = mix(emissive_color, emissive_color * final_copper_emissive, copper_total_match * factor_copper);
    #endif

    #if defined EMISSIVE_MATERIAL && defined GBUFFER_TERRAIN
        float factor_redmat = isType(emitter_type, 1); // Redstone
        float factor_solar  = isType(emitter_type, 2); // Solar panel
        float factor_cobs   = isType(emitter_type, 3); // Crying obsidian
        float factor_wh     = isType(emitter_type, 4); // White highlights
        float factor_fire   = isType(emitter_type, 5); // Fire
        float factor_sculk  = isType(emitter_type, 6); // Sculk
        /* new */
        float factor_glowstone  = isType(emitter_type, 15);
        float factor_sealantern = isType(emitter_type, 16);
        float factor_rslamp     = isType(emitter_type, 17);
        float factor_froglight  = isType(emitter_type, 18);
        float factor_shroom     = isType(emitter_type, 19);
        float factor_jack       = isType(emitter_type, 20);
        float factor_lantern    = isType(emitter_type, 21);
        float factor_soullant   = isType(emitter_type, 22);
        float factor_coppllant  = isType(emitter_type, 23);
        float factor_lava       = isType(emitter_type, 24);
        float factor_magma      = isType(emitter_type, 25);
        float factor_beacon     = isType(emitter_type, 26);
        float factor_endrod     = isType(emitter_type, 27);
        float factor_torch      = isType(emitter_type, 28);
        float factor_soultorch  = isType(emitter_type, 29);
        float factor_coppltorch = isType(emitter_type, 30);
        float factor_generic    = isType(emitter_type, 31);
        float factor_cbulb      = isType(emitter_type, 32);

        float factor_rail    = isType(emitter_type, 10); // Rails
        float factor_end     = isType(emitter_type, 11); // End Portal frame
        float factor_warped  = isType(emitter_type, 13); // Warped
        float factor_crimson = isType(emitter_type, 14); // Crimson
        
        // REDSTONE MATERIAL (emitter_type == 1)
        vec3 target_color_alt_redmat = vec3(1.0);
        vec3 target_color_alt2_redmat = vec3(0.75, 0.5, 0.0);
        vec3 target_color_redmat = vec3(1.0, 0.0, 0.0);
        vec3 target_color_light_redmat = vec3(1.0, 0.6, 0.6);
        
        float base_sat_lum_redmat = checkSat(saturation, 0.15, 1.0) * checkLum(luminance, 0.1, 1.0);
        float match_1_redmat = getColor(color, target_color_redmat, 0.3) * base_sat_lum_redmat;
        float match_2_redmat = getColor(color, target_color_light_redmat, 0.12) * checkLum(luminance, 0.0, 0.8) * checkSat(saturation, 0.3, 1.0);
        float match_3_redmat = getColor(color, target_color_alt_redmat, 0.07);
        float match_4_redmat = getColor(color, target_color_alt2_redmat, 0.8) * checkLum(luminance, 0.55, 1.0) * checkSat(saturation, 0.15, 1.0);
        
        vec3 final_emissive_redmat = vec3(1.0);
        float total_match_redmat = 0.0;
        
        final_emissive_redmat = mix(final_emissive_redmat, vec3(1.0, 0.5, 0.5) * vec3(30.0 * correct_light), match_1_redmat);
        total_match_redmat = max(total_match_redmat, match_1_redmat);
        final_emissive_redmat = mix(final_emissive_redmat, vec3(20.0 * correct_light) * vec3(1.0, 0.5, 0.5), match_2_redmat);
        total_match_redmat = max(total_match_redmat, match_2_redmat);
        final_emissive_redmat = mix(final_emissive_redmat, vec3(1.0, 0.5, 0.5) * 10.0 * pow(luma(tint_color.rgb), mix(0.5, dayBF(1.0, 1.1, 0.5), lmcoord_alt.y)) + gloss * correct_light, match_3_redmat); 
        total_match_redmat = max(total_match_redmat, match_3_redmat);
        final_emissive_redmat = mix(final_emissive_redmat, vec3(1.0, 0.5, 0.5) * vec3(10.0 * correct_light), match_4_redmat);
        total_match_redmat = max(total_match_redmat, match_4_redmat);
        
        emissive_color = mix(emissive_color, emissive_color * final_emissive_redmat, total_match_redmat * factor_redmat);
        
        // SOLAR PANEL (emitter_type == 2)
        vec3 target_color_dark_solar = vec3(1.0);
        float solar_match = getColor(color, target_color_dark_solar, 0.49) * checkSat(saturation, 0.0, 1.0) * checkLum(luminance, 0.1, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 10.0 * correct_light * color * color * block_luma, solar_match * factor_solar);
        
        // CRYING OBSIDIAN (emitter_type == 3)
        vec3 target_color_dark_cobs = vec3(0.25, 0.0, 0.5);
        vec3 target_color_light_cobs = vec3(0.75, 0.0, 1.0);
        float base_sat_cobs = checkSat(saturation, 0.5, 1.0);
        float match_1_cobs = getColor(color, target_color_dark_cobs, 0.01) * base_sat_cobs;
        float match_2_cobs = getColor(color, target_color_light_cobs, 0.25) * checkSat(saturation, 0.15, 1.0);

        float factor_cobs_1 = 5.0 * correct_light;
        float factor_cobs_2 = luma(color) * 30.0 * correct_light;
        
        vec3 final_emissive_cobs = mix(vec3(1.0), vec3(factor_cobs_1), match_1_cobs);
        final_emissive_cobs = mix(final_emissive_cobs, vec3(factor_cobs_2), match_2_cobs);
        
        float total_match_cobs = clamp(match_1_cobs + match_2_cobs, 0.0, 1.0);
        
        emissive_color = mix(emissive_color, emissive_color * final_emissive_cobs, total_match_cobs * factor_cobs);
        
        // WHITE HIGHLIGHTS (emitter_type == 4)
        vec3 target_color_dark_wh = vec3(0.5, 1.0, 1.0);
        vec3 target_color_dark_2_wh = vec3(0.75, 0.25, 0.5);
        vec3 target_color_light_wh = vec3(0.75);
        vec3 target_color_light_2_wh = vec3(0.686,0.686,0.525);
        
        float match_1_wh = getColor(color, target_color_dark_wh, 0.4) * checkLum(luminance, 0.5, 1.0);
        float match_2_wh = getColor(color, target_color_light_wh, 0.65) * checkLum(luminance, 0.99, 1.0);
        float match_3_wh = getColor(color, target_color_light_2_wh, 0.06) * checkSat(saturation, 0.1, 1.0);
        float match_4_wh = getColor(color, target_color_dark_2_wh, 0.28) * checkSat(saturation, 0.3, 1.0) * checkLum(luminance, 0.0, 1.0);
        
        vec3 final_emissive_wh = vec3(1.0);
        float total_match_wh = 0.0;
        
        final_emissive_wh = mix(final_emissive_wh, vec3(0.4, 0.8, 1.0) * 5 * correct_light * block_luma, match_1_wh);
        total_match_wh = max(total_match_wh, match_1_wh);
        final_emissive_wh = mix(final_emissive_wh, vec3(3.0) * correct_light * block_luma, match_2_wh);
        total_match_wh = max(total_match_wh, match_2_wh);
        final_emissive_wh = mix(final_emissive_wh, vec3(10.0) * correct_light * block_luma, match_3_wh);
        total_match_wh = max(total_match_wh, match_3_wh);
        final_emissive_wh = mix(final_emissive_wh, vec3(2.5) * correct_light, match_4_wh);
        total_match_wh = max(total_match_wh, match_4_wh);
        
        emissive_color = mix(emissive_color, emissive_color * final_emissive_wh, total_match_wh * factor_wh);
        
        // FIRE (emitter_type == 5)
        vec3 target_color_dark_fire = vec3(1.0, 0.5, 0.0);
        vec3 target_color_light_fire = vec3(1.0);
        
        float match_1_fire = getColor(color, target_color_dark_fire, 0.16) * checkSat(saturation, 0.0, 1.0) * checkLum(luminance, 0.2, 1.0);
        float match_2_fire = getColor(color, target_color_light_fire, 0.49) * checkSat(saturation, -0.1, 1.0) * checkLum(luminance, 0.9, 1.0);
        
        vec3 final_emissive_fire = vec3(1.0);
        float total_match_fire = 0.0;

        final_emissive_fire = mix(final_emissive_fire, 4.0 * correct_light * vec3(1.0, 0.5, 0.0) * block_luma, match_1_fire);
        total_match_fire = max(total_match_fire, match_1_fire);
        final_emissive_fire = mix(final_emissive_fire, vec3(5.0, 3.25, 1.5) * correct_light * block_luma, match_2_fire);
        total_match_fire = max(total_match_fire, match_2_fire);

        emissive_color = mix(emissive_color, emissive_color * final_emissive_fire, total_match_fire * factor_fire);
        
        // SCULK (emitter_type == 6)
        vec3 target_color_sculk = vec3(0.05, 0.7, 0.8);
        float distance_to_target_sculk = distance(color, target_color_sculk);
        float brightness_sculk = smoothstep(0.6, 0.0, distance_to_target_sculk) * 10.0;
        float match_sculk = checkSat(saturation, 0.5, 1.0) * checkLum(luminance, 0.2, 1.0);
        emissive_color = mix(emissive_color, emissive_color * (1.0 + brightness_sculk * correct_light), match_sculk * factor_sculk);
        
        // GLOWSTONE (emitter_type == 15)
        emissive_color = mix(emissive_color, emissive_color * mix(0.3, 0.6, checkLum(luminance, 0.5, 1.0)) / candle_color * mix(vec3(1.0, 0.7, 0.65) / sqrt(sqrt(luma(color))), vec3(1.0, 0.8, 0.6), checkLum(luminance, 0.5, 1.0)), factor_glowstone);

        // SEA LANTERN (emitter_type == 16)
        emissive_color = mix(emissive_color, emissive_color * 0.6 * saturate(color, -0.66) / candle_color / mix(sqrt(luma(color)) * 2.0, 1.0, checkLum(luminance, 0.6, 1.0)) / mix(1.0, sqrt(luma(color)) * 1.25, checkLum(luminance, 0.6, 1.0)), factor_sealantern);

        // REDSTONE LAMP (emitter_type == 17)
        emissive_color = mix(emissive_color, emissive_color * mix(0.15 / sqrt(luma(color)), 0.85, checkLum(luminance, 0.225, 1.0)) / candle_color, factor_rslamp);
        block_color.rgb = mix(block_color.rgb, block_color.rgb * vec3(1.0, 0.55, 0.45), checkLum(luminance, 0.225, 1.0) * factor_rslamp);

        // FROGLIGHT (emitter_type == 18)
        emissive_color = mix(emissive_color, emissive_color * 0.4 / candle_color, factor_froglight);
        block_color.rgb = mix(block_color.rgb, saturate(block_color.rgb, 2.0), factor_froglight);

        // SHROOMLIGHT (emitter_type == 19)
        emissive_color = mix(emissive_color, emissive_color * 0.55 / candle_color, factor_shroom);
        block_color.rgb = mix(block_color.rgb, saturate(block_color.rgb, 0.75), factor_shroom);

        // JACK O'LANTERN (emitter_type == 20)
        emissive_color = mix(emissive_color, emissive_color * 0.6 / candle_color * sqrt(color), factor_jack * checkLum(luminance, 0.7, 1.0));
        block_color.rgb = mix(block_color.rgb, block_color.rgb * (candle_color * 1.75), (1 - checkLum(luminance, 0.7, 1.0)) * factor_jack);

        // LANTERN (emitter_type == 21)
        float match_1_lantern = getColor(color, vec3(1.0, 0.6, 0.35), 0.5);
        emissive_color = mix(emissive_color, emissive_color * mix(0.2, pow(luma(color), 0.75) * 1.5, match_1_lantern) / candle_color, factor_lantern);
        block_color.rgb = mix(block_color.rgb, block_color.rgb * vec3(1.0, 0.55, 0.45), match_1_lantern * factor_lantern);

        // SOUL LANTERN (emitter_type == 22)
        float match_1_soullant = getColor(color, vec3(0.5, 0.9, 1.0), 0.5) * checkLum(luminance, 0.0, 1.0);
        emissive_color = mix(emissive_color, emissive_color * mix(0.2, luma(color) * sqrt(luma(color)) * 1.25, match_1_soullant) / candle_color, factor_soullant);
        block_color.rgb = mix(block_color.rgb, block_color.rgb * vec3(0.4, 0.8, 1.0), match_1_soullant * factor_soullant);

        // COPPER LANTERN (emitter_type == 23)
        float match_1_coppllant = getColor(color, vec3(0.5, 0.9, 0.001), 0.32) * checkLum(luminance, 0.425, 1.0);
        match_1_coppllant += getColor(color, vec3(0.7, 1.0, 0.6), 0.5) * checkLum(luminance, 0.7, 1.0);
        emissive_color = mix(emissive_color, emissive_color * mix(0.2, luma(color) * sqrt(luma(color)) * 1.333, min(match_1_coppllant, 1.0)) / candle_color, factor_coppllant);
        block_color.rgb = mix(block_color.rgb, block_color.rgb * vec3(0.7, 1.0, 0.7), match_1_coppllant * factor_coppllant);

        // LAVA (emitter_type == 24)
        float match_1_lava = getColor(color, vec3(1.0, 0.5, 0.0), 0.4) * checkSat(saturation, 0.5, 1.0) * checkLum(luminance, 0.2, 1.0);
        emissive_color = mix(emissive_color, emissive_color * 0.5 * vec3(1.0, 0.9, 1.0) / candle_color, match_1_lava * factor_lava);

        // MAGMA (emitter_type == 25)
        float match_1_magma = getColor(color, vec3(1.0, 0.5, 0.0), 0.4) * checkSat(saturation, 0.5, 1.0) * checkLum(luminance, 0.2, 1.0);
        float match_2_magma = getColor(color, vec3(1.0, 0.0, 0.0), 0.6) * checkSat(saturation, 0.0, 0.67) * checkLum(luminance, 0.0, 0.6);
        emissive_color = mix(emissive_color, emissive_color * 0.5 * vec3(1.0, 0.85, 1.0) / candle_color, match_1_magma * factor_magma);
        emissive_color -= mix(vec3(0.0), candle_color * correct_light, match_2_magma * factor_magma);

        // BEACON (emitter_type == 26)
        float match_1_beacon = getColor(color, vec3(0.0, 0.651, 1.0), 1.0);
        emissive_color = mix(emissive_color, emissive_color * 0.5 / candle_color, factor_beacon);
        emissive_color -= mix(vec3(0.0), (candle_color * 0.5) - gray(candle_color * 0.5) * correct_light, match_1_beacon * factor_beacon);

        // END ROD (emitter_type == 27)
        emissive_color = mix(emissive_color, emissive_color * 0.4 / candle_color, factor_endrod);

        // TORCH (emitter_type == 28)
        float match_torch = 1.0 - getColor(color, vec3(0.4353, 0.33, 0.2745), 0.22); // no stick
        emissive_color = mix(emissive_color, emissive_color * mix(vec3(0.6) * candle_color, vec3(0.9, 0.7, 0.6), match_torch) / candle_color, factor_torch);

        // SOUL TORCH (emitter_type == 29)
        emissive_color = mix(emissive_color, emissive_color * mix(candle_color, vec3(0.4, 0.5, 0.8), match_torch) / candle_color, factor_soultorch);

        // COPPER TORCH (emitter_type == 30)
        if(color.g - color.r > 0.22) {match_torch = 1.0;}
        emissive_color = mix(emissive_color, emissive_color * mix(vec3(0.6) * candle_color, vec3(0.6, 0.9, 0.6), match_torch) / candle_color, factor_coppltorch);

        // GENERIC MOD EMISSIVE (emitter_type == 31)
        emissive_color = mix(emissive_color, emissive_color * 1.75 * sqrt(luma(color)) * sqrt(color), factor_generic);

        // COPPER BULB (emitter_type == 32)
        float d_color = max_color - min_color;
        float match_1_cbulb = float(color.r >= color.g && color.g >= color.b)
                            * checkLum(max_color, 0.7, 1.0)
                            * step(0.325 * d_color, color.g - min_color)
                            * step(color.g - min_color, 0.842 * d_color)
                            * step(0.0001, d_color);
        emissive_color = mix(emissive_color, emissive_color * mix(vec3(0.15) / sqrt(luma(color)), vec3(1.0, 0.75, 0.5) * 0.8, match_1_cbulb * checkLum(luminance, 0.0, 1.0)) / candle_color, factor_cbulb);
        
        // RAIL (emitter_type == 10)
        vec3 target_color_rail = vec3(1.0, 0.0, 0.0);
        float rail_match = getColor(color, target_color_rail, 0.25);
        emissive_color = mix(emissive_color, emissive_color * 10.0 * vec3(1.0, 0.0, 0.0) * correct_light, rail_match * factor_rail);

        // END PORTAL FRAME (emitter_type == 11)
        vec3 target_color_end = vec3(1.0, 0.8, 1.0);
        vec3 target_color_end2 = vec3(0.0, 0.5333, 0.3725);
        
        float end_match = getColor(color, target_color_end, 0.4);
        float end_match2 = getColor(color, target_color_end2, 0.4) * checkSat(saturation, 0.2, 1.0);
        
        reflex_index2 = mix(reflex_index2, 0.5, end_match2 * factor_end);

        emissive_color = mix(emissive_color, emissive_color * 1.5 * correct_light + gloss, end_match * factor_end);
        emissive_color = mix(emissive_color, emissive_color * 3.5 * color + gloss,  end_match2 * factor_end);

        // NETHER (emitter_type == 13 & 14)
        vec3 target_color_warped = vec3(0.05, 0.7, 0.8);
        float distance_to_target_warped = distance(color, target_color_warped);
        float brightness_warped = smoothstep(0.8, 0.0, distance_to_target_warped) * 8.0;
        float match_warped = checkSat(saturation, 0.7, 1.0) * checkLum(luminance, 0.0, 0.5);
        emissive_color = mix(emissive_color, emissive_color * (1.0 + brightness_warped * correct_light), match_warped * factor_warped);

        vec3 target_color_crimson = vec3(1.0, 0.0, 0.0);
        float distance_to_target_crimson = distance(color, target_color_crimson);
        float brightness_crimson = smoothstep(0.6, 0.0, distance_to_target_crimson) * 25.0;
        float match_crimson = checkSat(saturation, 0.5, 1.0);
        emissive_color = mix(emissive_color, emissive_color * (1.0 + brightness_crimson * correct_light), match_crimson * factor_crimson);
    #endif
    }
#endif

#if defined GBUFFER_TEXTURED
    vec3 target_color_rain = vec3(0.5, 0.65, 1.0);
    float match_rain = getColor(pure_block_color.rgb, target_color_rain, 0.2);
    block_color = mix(block_color, block_color * 1.5, match_rain);
    block_color.a = mix(block_color.a, block_color.a * 0.25, match_rain);
#endif

#if (defined EMISSIVE_MATERIAL) && defined GBUFFER_ENTITIES
    if(entityId == 10200) { // DROWNED
        vec3 target_color_dr = vec3(0.561, 0.945, 0.843);
        vec3 target_color_dr2 = vec3(0.192, 0.678, 0.718);
        vec3 target_color_dr3 = vec3(0.396, 0.878, 0.867);

        float drowned_match = getColor(pure_block_color.rgb, target_color_dr, 0.01);
        float drowned_match2 = getColor(pure_block_color.rgb, target_color_dr2, 0.01);
        float drowned_match3 = getColor(pure_block_color.rgb, target_color_dr3, 0.01);

        emissive_color = mix(emissive_color, emissive_color * 5, drowned_match);
        emissive_color = mix(emissive_color, emissive_color * 5, drowned_match2);
        emissive_color = mix(emissive_color, emissive_color * 5, drowned_match3);
    }
#endif

#if defined GBUFFER_WEATHER
    vec3 target_color_rain = vec3(0.0, 0.7098, 1.0);
    float match_rain = getColor(pure_block_color.rgb, target_color_rain, 0.3);
    block_color = mix(block_color, saturate_v4(block_color * 1.5, 0.25), match_rain);
    block_color.a *= mix(0.2, 0.5, match_rain);
#endif

#if defined EMISSIVE_MATERIAL
    float factor_trim = isType(emitter_type, 12); // Armor trims
    emissive_color = mix(emissive_color, emissive_color * 4 * correct_light, factor_trim);

    #ifdef GBUFFER_HAND // Held Torch/Lantern
        float factor_soulTorchitem   = isType(emitter_type, 33);
        float factor_soullantItem    = isType(emitter_type, 34);
        float factor_copperTorchitem = isType(emitter_type, 35);
        float factor_coppllantItem   = isType(emitter_type, 36);
        float factor_torchItem       = isType(emitter_type, 37);
        float factor_lanternItem     = isType(emitter_type, 38);
        float factor_glowstoneItem   = isType(emitter_type, 39);
        float factor_sealanternItem  = isType(emitter_type, 40);

        float match_torch = 1.0 - getColor(color, vec3(0.4353, 0.33, 0.2745), 0.22); // no stick
        // Soul torch
        emissive_color = mix(emissive_color, emissive_color * mix(candle_color, vec3(0.4, 0.5, 0.8) * 0.4, match_torch) / candle_color, factor_soulTorchitem);
        
        // Copper torch
        if(color.g - color.r > 0.22) {match_torch = mix(0.0, 1.0, factor_copperTorchitem);}
        emissive_color = mix(emissive_color, emissive_color * mix(candle_color * 0.75, vec3(0.6, 0.9, 0.6) * 0.4, match_torch) / candle_color, factor_copperTorchitem);
        
        // Torch
        emissive_color = mix(emissive_color, emissive_color * mix(candle_color * 0.75, vec3(0.9, 0.7, 0.6) * 0.4, match_torch) / candle_color, factor_torchItem);

        // Lantern
        float match_1_lantern = getColor(color, vec3(1.0, 0.6, 0.35), 0.5);
        emissive_color = mix(emissive_color, emissive_color * mix(0.2, pow(luma(color), 0.75) * 0.75, match_1_lantern) / candle_color, factor_lanternItem);
        block_color.rgb = mix(block_color.rgb, block_color.rgb * vec3(1.0, 0.55, 0.45), match_1_lantern * factor_lanternItem);

        // Soul lantern
        float match_1_soullant = getColor(color, vec3(0.5, 0.9, 1.0), 0.5) * checkLum(luminance, 0.0, 1.0);
        emissive_color = mix(emissive_color, emissive_color * mix(0.05, luma(color) * sqrt(luma(color)) * 0.5, match_1_soullant) / candle_color, factor_soullantItem);
        block_color.rgb = mix(block_color.rgb, block_color.rgb * vec3(0.4, 0.8, 1.0), match_1_soullant * factor_soullantItem);

        // Copper lantern
        float match_1_coppllant = getColor(color, vec3(0.5, 0.9, 0.001), 0.32) * checkLum(luminance, 0.425, 1.0);
        match_1_coppllant += getColor(color, vec3(0.7, 1.0, 0.6), 0.5) * checkLum(luminance, 0.7, 1.0);
        emissive_color = mix(emissive_color, emissive_color * mix(0.2, luma(color) * sqrt(luma(color)) * 0.75, min(match_1_coppllant, 1.0)) / candle_color, factor_coppllantItem);
        block_color.rgb = mix(block_color.rgb, block_color.rgb * vec3(0.7, 1.0, 0.7), match_1_coppllant * factor_coppllantItem);

        // Glowstone
        emissive_color = mix(emissive_color, emissive_color * mix(0.3, 0.6, checkLum(luminance, 0.5, 1.0)) / candle_color * mix(vec3(1.0, 0.7, 0.65) / sqrt(sqrt(luma(color))), vec3(1.0, 0.8, 0.6), checkLum(luminance, 0.5, 1.0)), factor_glowstoneItem);

        // Sea lantern
        emissive_color = mix(emissive_color, emissive_color * 0.6 * saturate(color, -0.66) / candle_color / mix(sqrt(luma(color)) * 2.0, 1.0, checkLum(luminance, 0.6, 1.0)) / mix(1.0, sqrt(luma(color)) * 1.25, checkLum(luminance, 0.6, 1.0)), factor_sealanternItem);
    #endif
#endif

#ifdef GBUFFER_ENTITIES
    if(entityId == 10201) { // FIRE
        emissive_color *= 3.0 * vec3(1.0, 0.5, 0.25);
    }
#endif

block_color.rgb *= emissive_color;
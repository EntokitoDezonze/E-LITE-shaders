    if (textOpacity > 0.0) {
        // TITLE SPLASH

        beginText(fragPosMain, textPosMain);
            text.fgCol = vec4(vec3(2.0), textOpacity);
            text.bgCol = vec4(0.0);
            printString((_E, _minus, _L, _I, _T, _E, _space, _s, _h, _a, _d, _e, _r, _s, _space, _5));
            printLine();
        endText(block_color.rgb);

        // PROFILE SPLASH
        float subScale = 4.0;
        float subEntry = smoothstep(0.5, 1.5, frameTimeCounter);
        
        ivec2 fragPosSub = ivec2(gl_FragCoord.xy / subScale);
        int centerXSub = int((viewWidth / subScale) * 0.5);
        int posYSub = int((viewHeight * 0.825) / subScale);
        float slideUp = int(pow(1.0 - subEntry, 5.0) * 20.0);

        #if ACERCADE == 1
            int strW = 42; // Minimum (7*6)
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(1.4, 1.6, 2.0, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_M, _i, _n, _i, _m, _u, _m));
        #elif ACERCADE == 2
            int strW = 48; // Very low (8*6)
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(0.2, 0.2, 1.6, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_V, _e, _r, _y, _space, _l, _o, _w));
        #elif ACERCADE == 3
            int strW = 18; // Low (3*6)
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(0.0, 2.0, 2.0, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_L, _o, _w));
        #elif ACERCADE == 4
            int strW = 36; // Medium (6*6)
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(0.5, 2.0, 0.5, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_M, _e, _d, _i, _u, _m));
        #elif ACERCADE == 5
            int strW = 24; // High (4*6)
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(2.0, 2.0, 0.5, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_H, _i, _g, _h));
        #elif ACERCADE == 6
            int strW = 42; // Extreme (7*6)
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(1.6, 0.0, 0.0, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_E, _x, _t, _r, _e, _m, _e));
        #elif ACERCADE == 7
            int strW = 18; // MAX (3*6)
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(1.0, 0.2, 1.5, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_M, _A, _X));
        #endif

        printLine();
        endText(block_color.rgb);
    }
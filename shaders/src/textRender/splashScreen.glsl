if (textOpacity > 0.0 && hideGUI == false) {
        // TITLE SPLASH
        beginText(fragPosMain, textPosMain);
            text.fgCol = vec4(vec3(2.0), textOpacity);
            text.bgCol = vec4(0.0);
            printString((_E, _dash, _L, _I, _T, _E, _space, _s, _h, _a, _d, _e, _r, _s));
            printLine();
        endText(block_color.rgb);

        // PROFILE SPLASH
        subScale = 3 * (viewHeight / 1080);
        float subEntry = smoothstep(0.0, 1.0, frameTimeCounter);
        
        fragPosSub = ivec2(gl_FragCoord.xy / subScale);
        centerXSub = int((viewWidth / subScale) * 0.5);
        posYSub = int((viewHeight * 0.8375) / subScale);
        slideUp = int(cubePow(1.0 - subEntry) * 20.0);

        #if defined VOXY
            int envW = 42;
        #elif defined DISTANT_HORIZONS
            int envW = 24;
        #else
            int envW = 0;
        #endif

        #if ACERCADE == 1
            int strW = 42 + envW;
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(1.4, 1.6, 2.0, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_M, _i, _n, _i, _m, _u, _m));
        #elif ACERCADE == 2
            int strW = 48 + envW;
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(0.2, 0.2, 1.6, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_V, _e, _r, _y, _space, _l, _o, _w));
        #elif ACERCADE == 3
            int strW = 18 + envW;
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(0.0, 2.0, 2.0, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_L, _o, _w));
        #elif ACERCADE == 4
            int strW = 36 + envW;
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(0.5, 2.0, 0.5, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_M, _e, _d, _i, _u, _m));
        #elif ACERCADE == 5
            int strW = 24 + envW;
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(2.0, 2.0, 0.5, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_H, _i, _g, _h));
        #elif ACERCADE == 6
            int strW = 18 + envW;
            beginText(fragPosSub, ivec2(centerXSub - (strW / 2), posYSub - slideUp));
            text.fgCol = vec4(1.0, 0.2, 1.75, textOpacity * subEntry);
            text.bgCol = vec4(0.0);
            printString((_M, _A, _X));
        #endif

        #ifdef VOXY
            printString((_space, _dash, _space, _V, _o, _x, _y));
        #elif defined DISTANT_HORIZONS
            printString((_space, _dash, _space, _D, _H));
        #endif
        printLine();
        endText(block_color.rgb);
}
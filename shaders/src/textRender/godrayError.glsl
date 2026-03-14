float subScale = 6.0;
ivec2 fragPosSub = ivec2(gl_FragCoord.xy / subScale);
int centerXSub = int((viewWidth / subScale) * 0.5);
int posYSub = int((viewHeight * 0.57) / subScale);

// PRIMEIRA LINHA: Error
int strWErr = 30; // 5 * 6
beginText(fragPosSub, ivec2(centerXSub - (strWErr / 2), posYSub));
    text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
    text.bgCol = vec4(0.0);
    printString((_E, _r, _r, _o, _r));
    printLine();
endText(block_color.rgb);

subScale = 4.0;
fragPosSub = ivec2(gl_FragCoord.xy / subScale);
centerXSub = int((viewWidth / subScale) * 0.5);
posYSub = int((viewHeight * 0.47) / subScale);

int strWLog = 264; // 44 * 6
beginText(fragPosSub, ivec2(centerXSub - (strWLog / 2), posYSub));
    text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
    text.bgCol = vec4(0.0);
    printString((_V, _o, _l, _u, _m, _e, _t, _r, _i, _c, _space, _g, _o, _d, _r, _a, _y, _s, _space, _n, _e, _e, _d, _space, _s, _h, _a, _d, _o, _w, _s, _space, _t, _o, _space, _f, _u, _n, _c, _t, _i, _o, _n, _dot));
    printLine();
endText(block_color.rgb);
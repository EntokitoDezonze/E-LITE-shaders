#define ERROR2
subScale = 6 * (viewHeight / 1080);
fragPosSub = ivec2(gl_FragCoord.xy / subScale);
centerXSub = int((viewWidth / subScale) * 0.5);
posYSub = int((viewHeight * 0.57) / subScale);

strWErr = 42; // 7 * 6
beginText(fragPosSub, ivec2(centerXSub - (strWErr / 2), posYSub));
    text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
    text.bgCol = vec4(0.0);
    printString((_E, _r, _r, _o, _r, _space, _2));
    printLine();
endText(block_color.rgb);

subScale = 4 * (viewHeight / 1080);
fragPosSub = ivec2(gl_FragCoord.xy / subScale);
centerXSub = int((viewWidth / subScale) * 0.5);
posYSub = int((viewHeight * 0.47) / subScale);

// 34 * 6 = 204
int strWLog1 = 204; 
beginText(fragPosSub, ivec2(centerXSub - (strWLog1 / 2), posYSub));
    text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
    text.bgCol = vec4(0.0);
    printString((_V, _o, _x, _y, _space, _a, _n, _d, _space, _D, _i, _s, _t, _a, _n, _t, _space, _H, _o, _r, _i, _z, _o, _n, _s, _space, _d, _e, _t, _e, _c, _t, _e, _d, _dot));
    printLine(); 
    printLine();
endText(block_color.rgb);

// 41 * 6= 246
int strWLog2 = 246; 
beginText(fragPosSub, ivec2(centerXSub - (strWLog2 / 2), posYSub - 16 * viewHeight / 1080)); 
    text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);
    text.bgCol = vec4(0.0);
    printString((_D, _i, _s, _a, _b, _l, _e, _space, _o, _n, _e, _space, _t, _o, _space, _c, _o, _n, _t, _i, _n, _u, _e, _space, _u, _s, _i, _n, _g, _space, _t, _h, _e, _space, _s, _h, _a, _d, _e, _r, _dot));
    printLine();
endText(block_color.rgb);
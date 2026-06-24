subScale = 4 * viewHeight / 1080;
subEntry = smoothstep(0.0, 1.0, frameTimeCounter);

fragPosSub = ivec2(gl_FragCoord.xy / subScale);
centerXSub = int((viewWidth / subScale) * 0.5);
posYSub = int((viewHeight * 0.6) / subScale);
slideUp = int(pow(1.0 - subEntry, 5.0) * 20.0);

targetY = posYSub - int(slideUp);

int strWError1 = 402; 
beginText(fragPosSub, ivec2(centerXSub - (strWError1 / 2), targetY));
    text.fgCol = vec4(vec3(1), subEntry);
    text.bgCol = vec4(0.0);
    printString((_E, _r, _r, _o, _r, _space, _1, _colon, _space, _V, _o, _l, _dot, _space, _G, _o, _d, _r, _a, _y, _s, _space, _d, _o, _e, _s, _space, _n, _o, _t, _space, _w, _o, _r, _k, _space, _w, _i, _t, _h, _space, _s, _h, _a, _d, _o, _w, _space, _c, _a, _s, _t, _i, _n, _g, _space, _t, _u, _r, _n, _e, _d, _space, _o, _f, _f, _dot));
    printLine();
    printLine();
endText(block_color.rgb);

int strWError2 = 432; 
beginText(fragPosSub, ivec2(centerXSub - (strWError2 / 2), targetY - 8 * viewHeight / 1080)); 
    text.fgCol = vec4(vec3(1), subEntry);
    text.bgCol = vec4(0.0);
    printString((_E, _r, _r, _o, _r, _space, _2, _colon, _space, _V, _o, _x, _y, _space, _a, _n, _d, _space, _D, _i, _s, _t, _a, _n, _t, _space, _H, _o, _r, _i, _z, _o, _n, _s, _space, _c, _a, _n, _n, _o, _t, _space, _b, _e, _space, _t, _u, _r, _n, _e, _d, _space, _o, _n, _space, _a, _t, _space, _t, _h, _e, _space, _s, _a, _m, _e, _space, _t, _i, _m, _e, _dot));
    printLine();
endText(block_color.rgb);

position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
sub_position = gl_ModelViewMatrix * gl_Vertex;

if(dhMaterialId == DH_BLOCK_WATER) {  // Water
    position.y -= 0.125;
}

gl_Position = dhProjection * gbufferModelView * position;

#if AA_TYPE > 1
    gl_Position.xy += taa_offset * gl_Position.w;
#endif

// Fog intensity calculation
float fog_density_coeff = dayBF(
    FOG_SUNSET,
    FOG_DAY,
    FOG_NIGHT
) * (1/FOG_ADJUST);

gl_FogFragCoord = length(position.xyz);

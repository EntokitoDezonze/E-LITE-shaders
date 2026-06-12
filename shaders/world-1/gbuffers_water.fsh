#version 120
#include "/lib/extensions.glsl"
/* MakeUp - E-LITE shaders 5 - gbuffers_water.fsh
Render: Water and translucent blocks

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_WATER
#define WATER_F
#define NO_SHADOWS

#include "/common/water_blocks_fragment.glsl"

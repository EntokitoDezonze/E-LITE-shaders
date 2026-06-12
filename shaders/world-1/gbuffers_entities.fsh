#version 120
#include "/lib/extensions.glsl"
/* MakeUp - E-LITE shaders 5 - gbuffers_entities.fsh
Render: Droped objects, mobs and things like that

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define GBUFFER_ENTITIES
#define NO_SHADOWS

#include "/common/solid_blocks_fragment.glsl"
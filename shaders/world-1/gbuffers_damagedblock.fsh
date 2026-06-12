#version 120
#include "/lib/extensions.glsl"
/* MakeUp - E-LITE shaders 5 - gbuffers_damagedblock.fsh
Render: Damaged block effect

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NETHER
#define NO_SHADOWS
#define GBUFFER_DAMAGE

#include "/common/damage_fragment.glsl"
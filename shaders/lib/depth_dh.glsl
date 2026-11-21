/* MakeUp - E-LITE shaders 5 - depth_dh.glsl
Depth utilities (dh).

Javier Garduño - GNU Lesser General Public License v3.0
*/

float ld_dh(float depth) {
    return dhNearPlane / (dhFarPlane - depth * (dhFarPlane - dhNearPlane));
}

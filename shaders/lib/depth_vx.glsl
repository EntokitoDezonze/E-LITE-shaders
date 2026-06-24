/* MakeUp - E-LITE shaders 5 - depth_vx.glsl
Depth utilities (Voxy).

Javier Garduño - GNU Lesser General Public License v3.0
*/

float ld_vx(float depth) {
    const float vxNear = 16.0;
    const float vxFar  = 48000.0;
    return (2.0 * vxNear * vxFar) / (vxFar + vxNear - (2.0 * depth - 1.0) * (vxFar - vxNear));
}

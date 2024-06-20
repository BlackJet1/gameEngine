#version 300 es

in vec4 vPosition;
in vec2 vTex;
in vec4 vColor;
in float angle;
in float cx;
in float cy;

uniform vec4 camera;
uniform sampler2D tTexture;

out vec4 vCol;
out vec2 TexCoord;

void main(void)
{
    vec2 ofs = camera.zw;
    vec2 to = camera.xy;
    vec2 pos = vPosition.xy;
    pos-=vec2(cx, cy);
    vec2 rot=pos;
    pos.x=rot.x*cos(angle)-rot.y*sin(angle);
    pos.y=rot.x*sin(angle)+rot.y*cos(angle);
    pos+=vec2(cx, cy);
    pos = pos - to - ofs;
    pos.x = pos.x / ofs.x;
    pos.y = pos.y / ofs.y;

    gl_Position = vec4(pos.xy, vPosition.zw);
    vCol = vec4(vColor);
    TexCoord = vTex;
}
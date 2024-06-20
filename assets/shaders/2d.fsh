#version 300 es

precision mediump float;
in vec2 TexCoord;
in vec4 vCol;
uniform sampler2D tTexture;
out vec4 color;

void main()
{
    vec4 c=texture(tTexture, TexCoord);
    if (c.a<0.1) discard;

    color =c*vCol;
}
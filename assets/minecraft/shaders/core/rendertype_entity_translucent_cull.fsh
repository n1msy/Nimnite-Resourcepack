#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform sampler2D DiffuseSampler;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

in vec2 texCoord;
out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);


    //depth captures the item in inventory
    //float depth = -(ModelViewMat * vec4(1.0)).z;
    /*if (ivec4(texture(Sampler0, texCoord0) * 255) == ivec4(205, 164, 52, 255)) 
    {
        vec2 zoomedCoord = ((texCoord - vec2(0.5, 0.5)) * 0.2) + vec2(0.5, 0.5);
        //fragColor.rgb = vec3(3,0,0);
    }*/

    /*//captures the full map texture
    if (ivec4(texture(Sampler0, texCoord0) * 255) == ivec4(205, 164, 52, 255)) 
    {
      fragColor.rgb = vec3(3,0,0);
    }*/
}
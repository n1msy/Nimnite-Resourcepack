#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

vec2 guiPixel(mat4 ProjMat) {
	return vec2(ProjMat[0][0], ProjMat[1][1]) / 2.0;
}

const ivec2[] corners = ivec2[](
    ivec2(-1, -1),
    ivec2(-1, 1),
    ivec2(1, 1),
    ivec2(1, -1)
);

const int mapSize = 350;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    //capture map
    if (ivec4(texture(Sampler0, texCoord0) * 255) == ivec4(205, 164, 52, 255)) 
    {
        vec2 pixel = guiPixel(ProjMat);
        gl_Position = ProjMat * ModelViewMat * vec4(vec3(0, 0, 0), 1.0);
        gl_Position.xy += pixel.xy * corners[gl_VertexID % 4] * mapSize;
        gl_Position.y -= pixel.y * mapSize/4;
    }
}
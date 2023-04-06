#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

#moj_import <utils.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 normal;

flat out int isPost;

out vec4 pos;
out mat3 viewmat;
out vec2 proj;
out vec2 rotation;

out vec2 xy0;
out vec2 xy1;

const vec2[] corners = vec2[](
    vec2(0, 1), vec2(0, 0), vec2(1, 0), vec2(1, 1)
);

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    pos = vec4(0);
    viewmat = mat3(1, 0, 0, 0, 1, 0, 0, 0, 1);
    proj = vec2(0);
    xy0 = vec2(0);
    xy1 = vec2(0);
    
    isPost = 0;
    if (cc(texture(Sampler0, texCoord0), ivec4(255, 0, 0, 102))) {
        pos = vec4(0);
        viewmat = inverse(IViewRotMat);
        proj = vec2(ProjMat[0][0],ProjMat[1][1]);
        //gl_Position = vec4(0); //make all faces disappear
        if (gl_VertexID % 4 == 0) { //only get position from first vertex
            pos = vec4(IViewRotMat * Position, 1);
        }
        //if (gl_VertexID / 4 == 0) { //put that one face on screen for data
            vec2 screenPos = corners[gl_VertexID % 4]*2-1;
            gl_Position = vec4(screenPos, 0.0 + length(IViewRotMat * Position) * 0.001, 1.0);
        //}
        xy0 = vec2(0);
        if (gl_VertexID % 4 == 0 || gl_VertexID % 4 == 3) {
            xy0 = vec2((IViewRotMat * Position).y, 1);
        }
        xy1 = vec2(0);
        if (gl_VertexID % 4 == 1 || gl_VertexID % 4 == 2) {
            xy1 = vec2((IViewRotMat * Position).y, 1);
        }

        isPost = 1;
    } 
}

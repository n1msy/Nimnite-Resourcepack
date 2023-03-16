#version 150

#moj_import <fog.glsl>
#moj_import <map.glsl>
#moj_import <identifiers.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

flat out int type;
flat out vec4 ogColor;

vec2 guiPixel(mat4 ProjMat) {
	return vec2(ProjMat[0][0], ProjMat[1][1]) / 2.0;
}

//default - 128
const int mapSize = 150;
const int margin = 16;

const ivec2[] corners = ivec2[](
    ivec2(-1, -1),
    ivec2(-1, 1),
    ivec2(1, 1),
    ivec2(1, -1)
);

vec2 rotate(vec2 point, vec2 center, float rot) {
	float x = center.x + (point.x-center.x)*cos(rot) - (point.y-center.y)*sin(rot);
    float y = center.y + (point.x-center.x)*sin(rot) + (point.y-center.y)*cos(rot);

    return vec2(x, y);
}


//Each offset has one dedicated color (?)
vec3 getColor(int i) {
  switch (i) {

    //red
    //case 1:
    //  return vec3(255, 0, 0)/255.;
    //  break;

    case 4: case 6: case 8: case 10: case 12:
        return vec3(179, 255, 156)/255.;
        break;
 
    case 2: case 5: case 7: case 9: case 11: case 13:
        return vec3(222, 222, 222)/255.;
        break;

    case 16:
        return vec3(96, 224, 254)/255.;
        break;

    //empty health top UI and slot "NotSel" colors
    case 25: case 52: case 53: case 54: case 261:
        return vec3(170, 170, 170)/255.;
        break;

    //top left/right "dead" colors
    case 32: case 33:
        return vec3(200, 200, 200)/255.;
        break;

    //ability/ult point full
    case 38: case 40:
        return vec3(84, 242, 187)/255.;
        break;

    case 241:
        return vec3(252, 232, 40)/255.;
        break;

    case 251:
        return vec3(0, 240, 17)/255.;
        break;

    default:
        return vec3(1, 1, 1);
        break;
  }
}

#define PI 3.1415926535

//Bottom center
const int health = 10;
const int shield = 11;
const int ammo = 12;

//Top right (below minimap)
const int stats = 50;

//Bottom right
const int build = 30;
const int inv = 20;

//Right center (mats)
const int mat_icons = 40;
const int mat_wood = 41;
const int mat_brick = 42;
const int mat_metal = 43;

//Top left
const int p1_health_name = 60;
const int p1_health_bar = 61;

const int p2_health_name = 62;
const int p2_health_bar = 63;

const int p3_health_name = 64;
const int p3_health_bar = 65;

const int p4_health_name = 66;
const int p4_health_bar = 67;

void main() {
    ogColor = Color;

    //vanilla
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;

    // [ HUD ]
    // Text Offsets
    if (Color.r > 0 && Color.g == 0 && Color.b == 0)
    {
        vec2 pixel = guiPixel(ProjMat);

        //gl_Position = ProjMat * ModelViewMat * vec4(vec3(Position.x, Position.y, Position.z), 1.0);

        switch (int(Color.r*255))
        {
            //Agent Select Menu
            case stats:

                gl_Position.x += pixel.x * -6;
                gl_Position.y += gl_Position.w * 1 - pixel.y * -300;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            default:
                break;
        }

    }

    // [ MAP ]
    type = -1;
    bool map = texture(Sampler0, vec2(0, 0)).a == 254./255.;
    bool marker = texture(Sampler0, texCoord0) * 255 == vec4(173, 152, 193, 102);
    if (map || marker) {
        vec2 pixel = guiPixel(ProjMat);
        vec4 oldPos = gl_Position;

        gl_Position = ProjMat * ModelViewMat * vec4(vec3(0, 0, 0), 1.0);
        gl_Position.x *= -1;

        gl_Position.x += -pixel.x * (margin + mapSize);
        gl_Position.y += pixel.y * (margin + mapSize);
        vec2 center = gl_Position.xy;

        if (map) {
            gl_Position.xy += pixel.xy * corners[gl_VertexID % 4] * mapSize;
            type = MAP_TYPE;
        } else if (marker) {
            gl_Position.xy += pixel.xy * corners[gl_VertexID % 4] * 8;
            gl_Position.xy = rotate(gl_Position.xy / pixel.xy, center / pixel.xy, Color.r*PI*2) * pixel.xy;
            type = MARKER_TYPE;
        }
    } 
    if (type != -1 && Position.z == 0) {
        type = DELETE_TYPE;
    }

    //ogColor = texture(Sampler0, texCoord0);
}

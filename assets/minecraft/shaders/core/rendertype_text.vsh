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

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

out vec2 pos;

flat out float f1;
flat out float f2;
flat out int i1;
flat out int i2;
flat out int i3;

flat out float xOffset;
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

#define PI 3.1415926535

//Bottom center
const int health = 10;
const int health_max = 101;
const int shield = 11;
const int shield_max = 111;
const int ammo = 12;

//Top right (below minimap)
const int time = 50;
const int alive = 51;
const int kills = 52;

//Bottom right
const int build = 30;
const int inv = 20;

//Right center (mats)
const int mat_wood = 41;
const int mat_brick = 42;
const int mat_metal = 43;

//Top left
const int player_1 = 61;
const int player_2 = 62;
const int player_3 = 63;
const int player_4 = 64;

//yaw (top UI)
const int yaw = 65;

//medkit, shields, etc
const int load = 66;

const int build_keys = 67;
const int build_toggle = 68;

const int inv_keys = 69;
const int inv_toggle = 70;

//build text guide
const int build_text = 71;
const int build_brackets = 72;
const int build_left = 73;
const int build_right = 74;
const int build_drop = 75
;
//Each offset has one dedicated color (?)
vec3 getColor(int i) {
  switch (i) {

    //red
    //case 1:
    //  return vec3(255, 0, 0)/255.;
    //  break;

    case shield_max:
        return vec3(186, 233, 255)/255.;
        break;

    case health_max:
        return vec3(209, 255, 196)/255.;
        break;

    case build_brackets:
        return vec3(170, 170, 170)/255.;
        break;

    case build_left:
        return vec3(255, 85, 85)/255.;
        break;

    case build_right:
        return vec3(85, 85, 255)/255.;
        break;

    case build_drop:
        return vec3(255, 255, 85)/255.;
        break;

    default:
        return vec3(1, 1, 1);
        break;
  }
}

void main() {
    ogColor = Color;

    //vanilla
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;

    vec2 pixel = guiPixel(ProjMat);

    //SHADOW REMOVER Cred: PuckiSilver
    //Use this color code to remove it: #4e5c24
    if (Color == vec4(78/255., 92/255., 36/255., Color.a) && Position.z == 0.03) {
        vertexColor = texelFetch(Sampler2, UV2 / 16, 0); // remove color from no shadow marker
    } else if (Color == vec4(19/255., 23/255., 9/255., Color.a) && Position.z == 0) {
        vertexColor = vec4(0); // remove shadow
    } else if (Color == vec4(16/255., 0., 0., Color.a) && Position.y > 22){
        //remove the color of the shadow from the yaw number text
        //make sure w others it's fine to do this
        vertexColor = vec4(0);
    }
    //move the actionbar's shadows up
    else if (Color == vec4(18/255., 0., 0., Color.a) && Position.y < 450 || (Color == vec4(17/255., 0., 0., Color.a) && Position.y < 450)){
        gl_Position.y += pixel.y * -50;
    }

    //if (ivec4(texture(Sampler0, texCoord0) * 255) == ivec4(137, 97, 160, 82))

    // [ HUD ]

    // Text Offsets
    if (Color.r > 0 && Color.g == 0 && Color.b == 0)
    {

        //gl_Position = ProjMat * ModelViewMat * vec4(vec3(Position.x, Position.y, Position.z), 1.0);

        switch (int(Color.r*255))
        {

            case yaw:
                gl_Position.x += pixel.x * -2;
                gl_Position.y += gl_Position.w * pixel.y * -38;

                vertexColor.rgb = getColor(int(Color.r*255));

                break;

            case mat_wood:
                gl_Position.x += pixel.x * 764;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 304;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case mat_brick:
                gl_Position.x += pixel.x * 844;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 322;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case mat_metal:
                gl_Position.x += pixel.x * 924;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 340;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case time:
                gl_Position.x += pixel.x * 728;
                gl_Position.y += gl_Position.w * 1 - pixel.y * -328;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case alive:
                gl_Position.x += pixel.x * 834;
                gl_Position.y += gl_Position.w * 1 - pixel.y * -310;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case kills:
                gl_Position.x += pixel.x * 938;
                gl_Position.y += gl_Position.w * 1 - pixel.y * -293;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case player_1:
                gl_Position.x += gl_Position.w * -2 + pixel.x * 1056;
                gl_Position.y += gl_Position.w - pixel.y * -20;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case ammo:
                gl_Position.x += gl_Position.w * -1 + pixel.x * 940;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 60;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case shield: case shield_max:
                gl_Position.x += gl_Position.w * -1 + pixel.x * 791.5;
                gl_Position.y += gl_Position.w * -1 - pixel.y * -10;

                vertexColor.rgb = getColor(int(Color.r*255));

                break;

            case health: case health_max:
                gl_Position.x += gl_Position.w * -1 + pixel.x * 791.5;
                gl_Position.y += gl_Position.w * -1 - pixel.y * -20;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case inv:
                gl_Position.x += pixel.x * 411;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 75;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case build:
                gl_Position.x += pixel.x * 513;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 175;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case load:
                gl_Position.y += pixel.y * -50;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case build_keys:
                gl_Position.x += gl_Position.w * pixel.x * 621;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 220;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case build_toggle:
                gl_Position.x += gl_Position.w * pixel.x * 472;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 155;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case inv_keys:
                gl_Position.x += gl_Position.w * pixel.x * 533;
                gl_Position.y += gl_Position.w * -1 - pixel.y * -17;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;

            case inv_toggle:
                gl_Position.x += gl_Position.w * pixel.x * 371;
                gl_Position.y += gl_Position.w * -1 - pixel.y * 49;

                vertexColor.rgb = getColor(int(Color.r*255));
                break;
            case build_text: case build_brackets: case build_left: case build_right: case build_drop:
                gl_Position.y += pixel.y * -50;

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
        gl_Position = ProjMat * ModelViewMat * vec4(vec3(0, 0, 0), 1.0);
        gl_Position.x *= -1;

        gl_Position.x += -pixel.x * (margin + mapSize);
        gl_Position.y += pixel.y * (margin + mapSize);
        vec2 center = gl_Position.xy;

        if (map) {
            gl_Position.xy += pixel.xy * corners[gl_VertexID % 4] * mapSize;
            type = MAP_TYPE;
        } else if (marker) {
            //full map marker
            //this will only ever break if the player is in the bottom left corner (it'll disappear)
            //since it's 0,0
            float rot = Color.r;
            if (Color.g*255.0 > 0 || Color.b*255 > 0){
                //full map marker
                //center
                gl_Position = ProjMat * ModelViewMat * vec4(vec3(0, 0, 1.0), 1.0);
                gl_Position.x += gl_Position.w;
                gl_Position.y += pixel.y * 396;
                //top left corner
                gl_Position.xy -= pixel.xy * 344;
                //actual position
                ivec3 c = ivec3(ogColor.rgb * 255);
                float x = c.g + c.r % 128 / 64 * 256;
                float y = c.b + c.r / 128 * 256;
                gl_Position.xy += pixel.xy * 688 * vec2(x / 512., y / 512.);
                center = gl_Position.xy;
                rot = c.r % 64 / 64.;
            }
            gl_Position.xy += pixel.xy * corners[gl_VertexID % 4] * 8;
            gl_Position.xy = rotate(gl_Position.xy / pixel.xy, center / pixel.xy, rot*PI*2) * pixel.xy;
            type = MARKER_TYPE;
        }
    // [ COMPASS ]
    } else if (texture(Sampler0, vec2(0, 0)) * 255 == vec4(9, 185, 21, 102)) {
        gl_Position = ProjMat * ModelViewMat * vec4(0, 0, 0, 1.0);
        gl_Position.x += gl_Position.w;
        gl_Position.y += pixel.y * 60;
        gl_Position.xy += pixel * corners[gl_VertexID % 4] * ivec2(COMPASS_WIDTH * 0.5, 12) * 3;

        type = COMPASS_TYPE;
        offset = (Color.r * 255 + mod(Color.b * 255, 4) * 256) / 1024.;
        oldOffset = (Color.g * 255 + (int(Color.b * 255) % 16)/ 4 * 256) / 1024.;
        serverTime = int(Color.b * 255) % 64 / 16;
    // [ PREVIEW CIRCLE ]
    } else if (ivec4(texture(Sampler0, texCoord0) * 255) == ivec4(157, 146, 163, 102)) {
        xOffset = gl_Position.x / pixel.x;

        gl_Position = ProjMat * ModelViewMat * vec4(vec3(0, 0, 0), 1.0);
        gl_Position.x *= -1;

        gl_Position.x += -pixel.x * (margin + mapSize);
        gl_Position.y += pixel.y * (margin + mapSize);
        gl_Position.xy += pixel.xy * corners[gl_VertexID % 4] * mapSize;
        pos = corners[gl_VertexID % 4];

        // read data
        ivec3 c = ivec3(ogColor.rgb * 255.);
        relX = c.r + (c.b % 8) * 256 - 1024;
        relY = c.g + (c.b % 64 / 8) * 256 - 1024;
        stormId = int(round(xOffset))/2 + (c.b / 64) * 4;

        type = CIRCLE_TYPE;

    // [ FULL CIRCLE ]
    } else if (ivec4(texture(Sampler0, texCoord0) * 255) == ivec4(109, 78, 129, 105)) {
        xOffset = gl_Position.x / pixel.x;

        gl_Position = ProjMat * ModelViewMat * vec4(vec3(0, 0, 1.0), 1.0);
        gl_Position.x += gl_Position.w;

        //gl_Position.x += -pixel.x;
        gl_Position.y += pixel.y * 396;

        gl_Position.xy += pixel.xy * corners[gl_VertexID % 4] * 344;

        pos = corners[gl_VertexID % 4];

        // read data
        ivec3 c = ivec3(ogColor.rgb * 255.);
        relX = c.r + (c.b % 4) * 256;
        relY = c.g + (c.b % 16 / 4) * 256;
        stormId = c.b / 16;
        type = FULL_CIRCLE_TYPE;

    // [ HEALTH BAR ]
    } else if (ivec4(texture(Sampler0, texCoord0) * 255) == ivec4(163, 93, 35, 58)) {

        //0 = health
        //1 = shield

        //big health bar
        if (Color.g*255 == 0.){
            gl_Position.x += gl_Position.w * -1 + pixel.x * 791.5;
            if (Color.b*255. == 0.){
                gl_Position.y += gl_Position.w * -1 - pixel.y * -20;
            } else{
                gl_Position.y += gl_Position.w * -1 - pixel.y * -10;
            }
        //small corner health bar
        } else{
            gl_Position.x += gl_Position.w * -2 + pixel.x * 1056;
            gl_Position.y += gl_Position.w - pixel.y * -20;
        }

        pos = (corners[gl_VertexID % 4] / 2.) + 0.5;
        type = HEALTH_TYPE;
    }

    if (type > -1 && Position.z == 0) {
        type = DELETE_TYPE;
    }

    //scaled with screen size
    //gl_Position.xy *= pos.x;

    //ogColor = texture(Sampler0, texCoord0);
}

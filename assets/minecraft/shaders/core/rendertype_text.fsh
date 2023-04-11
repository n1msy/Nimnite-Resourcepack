#version 150

#moj_import <fog.glsl>
#moj_import <map.glsl>
#moj_import <identifiers.glsl>

#define PI 3.1415926535

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform vec2 ScreenSize;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

in vec2 pos;

flat in float f1;
flat in float f2;
flat in int i1;
flat in int i2;
flat in int i3;

flat in float xOffset;
flat in int type;
flat in vec4 ogColor;

out vec4 fragColor;

//default = 0.5
const float zoom = 0.5; 

//slider fade
const float fadeTo = 0.1;

float getCloser(float a, float b) {
    float diff = b - a;
    if (abs(diff) > 0.5) {
        return a + sign(diff);
    } else {
        return a;
    }
}

float square(float x) {
  return x*x;
}

void main() {
    // vanilla 
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if ((color.a < 0.1 && type == -1) || type == DELETE_TYPE) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    // Remove sidebar background and red text (the rest is removed in position_color.fsh)
    if((isScoreboard(fragColor)) && ((ScreenSize.x - gl_FragCoord.x) < 36)) discard;

    // map
    if (type == MAP_TYPE) {
        getInfoFromColor(ogColor);


        vec2 c0 = texCoord0 + coords - vec2(0.5, 0.5);

        vec2 mapFrom = vec2(0, 0);
        if (displayId == 1 || displayId == 3) {
            if (coords.y > 0.5) mapFrom.y += 1;
                else mapFrom.y -= 1;
        }
        if (displayId == 2 || displayId == 3) {
            if (coords.x > 0.5) mapFrom.x += 1;
                else mapFrom.x -= 1;
        }

        vec2 c1 = mix(c0, coords, zoom);

        fragColor = texture(Sampler0, c1);
        // return opacity back to 255
        fragColor.a = 1;

        //make the edge colors blue, since it's the color of the water rgba(61,61,242,255)
        if (any(lessThan(c1, mapFrom)) || any(greaterThan(c1, mapFrom + vec2(1, 1)))) {
            if (displayId == 0) fragColor = vec4(53/255., 110/255., 185/255., 1);
                else discard;
        }

        //white border
        if (any(lessThan(texCoord0, vec2(0.01, 0.01))) || any(greaterThan(texCoord0, vec2(0.99, 0.99)))) {
            if (displayId == 0) fragColor = vec4(1, 1, 1, 0.5);
                else discard;
        }

        //dot
        //if (all(greaterThan(texCoord0, vec2(0.49, 0.49))) && all(lessThan(texCoord0, vec2(0.51, 0.51)))) fragColor = vec4(1, 1, 1, 1);
        
    } else if (type == MARKER_TYPE) {
        fragColor = texture(Sampler0, texCoord0);
        //so background of the character is removed too when displayed in full map
        if (fragColor != vec4(1,1,1,1)) discard;
    } else if (type == COMPASS_TYPE) {
        float tickDelta = fract(GameTime * 24000);
        if (serverTime != int(GameTime * 24000) % 4) tickDelta = 1;

        vec2 sliderOffset = vec2(-(COMPASS_WIDTH * 0.5)/256. + mix(oldOffset, getCloser(offset, oldOffset), tickDelta) + 0.5, 0);
        vec2 newCoord = texCoord0 * vec2(COMPASS_WIDTH/256., 1) + sliderOffset;

        fragColor = texture(Sampler0, newCoord);
        if (fragColor.a < 0.1 || fragColor * 255 == vec4(9, 185, 21, 102))
            discard;

        fragColor.a *= min(texCoord0.x/fadeTo, 1) - max((texCoord0.x-1+fadeTo)/fadeTo, 0);

    } else if (type == CIRCLE_TYPE) {
        vec2 circlePos = vec2(relX, relY) / 128.; // 1 is 128 blocks
        vec2 zoomedPos = pos * (1-zoom);

        // distance from line
        float dist = abs((circlePos.y-0)*pos.x-(circlePos.x-0)*pos.y+circlePos.x*0-circlePos.y*0)/sqrt(square(circlePos.y-0)+square(circlePos.x-0));

        //circle
        if (length(circlePos - zoomedPos) < 1 && length(circlePos - zoomedPos) > 0.98) {
            //fragColor = vec4(0, 0, stormId/255., 1);
            fragColor = vec4(1, 1, 1, 1);
        //line 
        } else if (dist < 0.02 && length(circlePos - zoomedPos) > 0.98) {
            if (length(circlePos) > length(circlePos - zoomedPos)) {
                fragColor = vec4(1, 1, 1, 1);
            } else
                discard;
        } else 
            discard;
        

        //else discard;
        //remove anything behind the marker (0,0)
        //if (pos.y > 0) discard;

        //remove at border
        if (any(lessThan(pos/2+0.5, vec2(0.01, 0.01))) || any(greaterThan(pos/2+0.5, vec2(0.99, 0.99)))) discard;

    } else if (type == FULL_CIRCLE_TYPE) {

        vec2 circlePos = vec2(relX, relY) / 512.; // 1 is 128 blocks

        // distance from line
        float dist = abs((circlePos.y-0)*pos.x-(circlePos.x-0)*pos.y+circlePos.x*0-circlePos.y*0)/sqrt(square(circlePos.y-0)+square(circlePos.x-0));

        //circle
        if (length(circlePos - pos) < 0.25 && length(circlePos - pos) > 0.24)
        {
            //fragColor = vec4(0, 0, stormId/255., 1);
            fragColor = vec4(1, 1, 1, 1);
        //line 
        } 
        else if (dist < 0.02 && length(circlePos - pos) > 0.98) 
        {
            if (length(circlePos) > length(circlePos - pos)) 
            {
                fragColor = vec4(1, 1, 1, 1);
            } else
                discard;
        } else 
            discard;

    } else if (type == HEALTH_TYPE){

        //returns 0 to 1
        float health = ogColor.r;
        vec4 barColor;

        if (ogColor.b*255. == 0.){
            //health color
            barColor = vec4(90/255.,196/255.,55/255.,1);
        } else{
            //shield color
            barColor = vec4(39/255.,158/255.,214/255.,1);
        }

        fragColor = texture(Sampler0, texCoord0);

        //remove the corner encoded pixels
        if (fragColor.a == 58/255.) discard;

        //health bar
        if (pos.x <= health && fragColor.a != 0){
            fragColor = barColor;
        }

        //remove the corner encoded pixels
        if (fragColor.a == 58/255.) discard;

    }
}

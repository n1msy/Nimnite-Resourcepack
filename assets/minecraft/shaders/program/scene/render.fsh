#version 330

uniform sampler2D DiffuseSampler;
uniform sampler2D DepthSampler;
uniform sampler2D StorageSampler;

uniform vec2 OutSize;
uniform float MainColorMult;

uniform float Time;

in vec2 texCoord;
in vec2 OneTexel;
in vec2 ratio;
in vec3 position;
in mat3 viewmat;
in vec2 proj;
flat in int nobjs;

out vec4 fragColor;

in float borderSize;
float borderRadius;

#define AA 1

#define renderdistance 200

#define PI 3.14159265358979323846

#define FPRECISION 2000000.0
int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int s = ivec.b >= 128.0 ? -1 : 1;
    return s * (int(ivec.r) + int(ivec.g) * 256 + (int(ivec.b) - 64 + s * 64) * 256 * 256);
}
float decodeFloat(vec3 ivec) {
    return decodeInt(ivec) / FPRECISION;
}
#define near 0.05
#define far  1000.0
float linearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));
}
//--------------------------------------------------------------------------------
//sdfs
struct obj {float depth; int type;};
obj Sphere  (vec3 p, float r,       int type) {return obj(length(p.xz)-r, type);}

//--------------------------------------------------------------------------------
//scene
obj hit(in vec3 pos) {//obj     pos                     size                    material    smoothness
    obj o = Sphere( pos + vec3(0,0,0), borderRadius, 3 );
    
    return o;
}


//--------------------------------------------------------------------------------
//drawing
float tick(float x, float y) {
    return x - mod(x, y);
}

vec4 render(vec3 position, vec3 rotation, float fardepth, vec4 maincolor) {
    //raymarching
    float t = 0.;
    obj o;
    float h;
    bool wasHit = false;
    bool inside = false;
    for(int i = 0; i < 100; i++) {
        o = hit(position + t*rotation);
        //if (h.depth < o.depth) o = h;
        //if hit
        if (o.depth < 0.0001) {
            if (!wasHit) h = t;
            wasHit = true;
            if (i == 0) inside = true;
        }
        if (o.depth > 0.0001 && wasHit) break;
        t += wasHit ? abs(o.depth)+0.01 : o.depth;
        //exceed far plane

        if (t >= fardepth) break;
    }
    vec4 color = maincolor;
    //scene
    if (t < fardepth) {
        vec3 pos = position + t*rotation;
        vec3 borderColor = vec3(15, 95, 185)/255.;
        float border = (atan(pos.x, pos.z) + PI) / (2*PI);
        vec2 tileCoords = vec2(mod(border, 0.625/borderRadius)/(0.625/borderRadius), mod(pos.y, 3) / 3);
        float tileSize = (sin((tick(pos.y, 3))/10.+Time*PI*2)/2+0.5)/4+0.05;
        color = vec4(borderColor, 0.6);
        if (all(greaterThan(tileCoords, vec2(tileSize, tileSize))) && all(lessThan(tileCoords, vec2(1-tileSize, 1-tileSize)))) {
            color += vec4(1, 1, 2, 0.5)*0.125*clamp((t-10)/20, 0, 1)*clamp((60-pos.y)/40, 0, 1);
        }

        vec2 squareCoords = vec2(mod(border, 0.0625/borderRadius)/(0.0625/borderRadius), mod(pos.y, 0.4) / 0.4);
        float squareSize = (sin((tick(pos.y, 0.4))+tick(border, 0.0625/borderRadius)/(0.0625/borderRadius)*0.4+Time*PI*2)/2+0.5)/4+0.05;
        if (all(greaterThan(squareCoords, vec2(squareSize, squareSize))) && all(lessThan(squareCoords, vec2(1-squareSize, 1-squareSize)))) {
            color += vec4(0.2, 0.2, 3.5, 3)*0.125*clamp((15-t)/10, 0, 1);
        }

        color += vec4(1, 1, 1, 1) * tick(1.4 - clamp(fardepth-t, 0, 1), 0.5);
        color.a *= clamp((110-pos.y)/80, 0, 0.7) * clamp((renderdistance-t)/10, 0, 1);

        //color = vec4(squareSize, 0, 0, 1);
    }
    if (h < fardepth && wasHit && !inside) {
        t = h;
        // copy of the above code
        vec3 pos = position + t*rotation;
        vec3 borderColor = vec3(15, 95, 185)/255.;
        float border = (atan(pos.x, pos.z) + PI) / (2*PI);
        vec2 tileCoords = vec2(mod(border, 0.625/borderRadius)/(0.625/borderRadius), mod(pos.y, 3) / 3);
        float tileSize = (sin((tick(pos.y, 3))/10.+Time*PI*2)/2+0.5)/4+0.05;
        vec4 scolor = vec4(borderColor, 0.6);
        if (all(greaterThan(tileCoords, vec2(tileSize, tileSize))) && all(lessThan(tileCoords, vec2(1-tileSize, 1-tileSize)))) {
            scolor += vec4(1, 1, 2, 0.5)*0.125*clamp((t-10)/20, 0, 1)*clamp((60-pos.y)/40, 0, 1);
        }

        vec2 squareCoords = vec2(mod(border, 0.0625/borderRadius)/(0.0625/borderRadius), mod(pos.y, 0.4) / 0.4);
        float squareSize = (sin((tick(pos.y, 0.4))+tick(border, 0.0625/borderRadius)/(0.0625/borderRadius)*0.4+Time*PI*2)/2+0.5)/4+0.05;
        if (all(greaterThan(squareCoords, vec2(squareSize, squareSize))) && all(lessThan(squareCoords, vec2(1-squareSize, 1-squareSize)))) {
            scolor += vec4(0.2, 0.2, 3.5, 3)*0.125*clamp((15-t)/10, 0, 1);
        }

        //

        scolor += vec4(1, 1, 1, 1) * tick(1.4 - clamp(fardepth-t, 0, 1), 0.5);
        scolor.a *= clamp((110-pos.y)/80, 0, 0.7) * clamp((renderdistance-t)/10, 0, 1);

        color = scolor + color * color.a;
    }
    //if (fucked) color = vec4(1, 0, 0, 1);

    //world
    

    //return color
    color = clamp(color, 0.0, 1.0);
    return color;
}
//--------------------------------------------------------------------------------

void main() {
    borderRadius = borderSize*100;

    //data
    vec4 color = vec4(0);
    vec4 maincolor = texture(DiffuseSampler, texCoord) * MainColorMult;
    //vec4 maincolor = vec4(0);
    float depth = linearizeDepth(texture(DepthSampler, texCoord).r);

    vec2 uv = (texCoord * 2 - 1);

    //ray start
    vec3 ro = position;
    vec3 rd = viewmat * vec3(uv/proj,-1);
    //warp depth to fov
    float l = length(rd);
    rd /= l;
    depth = depth * l;
    //render
    color += render(ro, rd, min(depth, renderdistance), vec4(0));
    // alpha blend with maincolor
    if (MainColorMult > 0) color = maincolor * (1 - color.a) + vec4(color.rgb * color.a, color.a);

    fragColor = color;
}

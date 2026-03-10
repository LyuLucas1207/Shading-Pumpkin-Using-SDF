
uniform vec3 resolution;   
uniform float time;   
uniform vec3 camPos;   

// NOTE: modify these to control performance/quality tradeoff
#define MAX_STEPS 50 // max number of steps to take along ray
#define MAX_DIST 50. // max distance to travel along ray

#define HIT_DIST .01 // distance to consider as "hit" to surface
#define PUMPKIN_CENTER vec3(0,0.7,5) 

/*
SDF: Signed Distance Function

d > 0: outside the surface
d < 0: inside the surface
d = 0: on the surface

*/

/*
 * Helper: rotate point p around Z axis by angle (in degrees).
 */
vec3 rotZ(vec3 p, float angle) {
    float s = sin(radians(angle));
    float c = cos(radians(angle));
    return mat3(
        c, -s, 0,
        s, c, 0.0,
        0, 0, 1) * p; 
}

/*
 * Helper: determines the material ID based on the closest distance.
 * vec2(distance, material ID)
 * d1 = vec2(0.3, 2.0);   // 南瓜
 * d2 = vec2(0.1, 1.0);   // 地面
 * getMaterial(d1, d2) will return 2.0 because 0.3 < 0.1
 */
float getMaterial(vec2 d1, vec2 d2) {
    return (d1.x < d2.x) ? d1.y : d2.y;
}

/*
 * Hard union of two SDFs.
 */
float unionSDF( float d1, float d2 )
{
	/**
     * TODO: Implement the union of two SDFs.
     * !d1 is the distance between the point and the surface, d2 is the distance between the point and the surface.
     * !The union of two SDFs is the minimum of the two distances.
     * !如果有两个小球，和一个点，距离小球的距离为0.3和0.1，那么问这个点离整体（两个小球）的距离是多少？
     */
    return min(d1, d2);
}

/*
 * Hard difference of two SDFs.
 */
float subtractionSDF(float d1, float d2)
{   
	/**
     * TODO: Implement the union of two SDFs.
     * !从物体A里面挖去物体B，问这个点离整体（物体A和物体B）的距离是多少？
     * !保留A, 但把落在B里面的部分去掉, 所以距离为max(d1, -d2)
     * !Original:
     * inside: d2 < 0
     * outside: d2 > 0
     * !After:
     * inside: -d2 > 0
     * outside: -d2 < 0
     * A is the Pumpkin, B is the Eyes
     * subtractionSDF(Pumpkin, Eyes) = max(Pumpkin, -Eyes) => A is kept, But the part that is inside B is removed
     */

    return max(d1, -d2);
}   

/*
 * Smooth union of two SDFs.
 * Resource: `https://iquilezles.org/articles/smin/`
 * quadratic polynomial
 */
float smoothUnionSDF( float d1, float d2, float k )
{
	/**
     * TODO: Implement the smooth union of two SDFs.
     * !Clamp the result to be between 0 and 1
     * clamp(x, min, max): if x is less than min, return min, if x is greater than max, return max, otherwise return x
     * mix(a, b, t) =  t(b-a) + a
     */

    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

/*
 * Smooth difference of two SDFs.
 */
float smoothSubtractionSDF(float d1, float d2, float k)
{
    /**
     * TODO: Implement the smooth difference of two SDFs.
     * !Use smoothUnionSDF to implement smoothSubtractionSDF
     * HINT: you may be able to use smoothUnionSDF
     */
    return smoothUnionSDF(d1, -d2, k);
}


/*
 * Computes the signed distance function (SDF) of a plane.
 * https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the plane.
 *    - An identifier for material type.
 */
vec2 Plane(vec3 p)
{
    vec3 n = vec3(0, 1, 0); // Normal of the plane
    float h = 0.0; // Height offset
    return vec2(dot(p, n) + h, 1.0);
}

/*
 * Sphere SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the sphere.
 *  - r: The radius of the sphere.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the sphere.
 *    - An identifier for material type.
 */
vec2 Sphere(vec3 p, vec3 c, float r)
{
    /**
     * TODO: Implement the signed distance function for a sphere.
     * !The distance between a point and a sphere is the length of the vector from the point to the center of the sphere minus the radius of the sphere
     * !d = |p - c| - r
    */
    vec3 cp = p - c; // distance from the center of the sphere to the point
    float dist = length(cp) - r;
    return vec2(dist, 2.0);

}

/*
 * Cylinder SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the cylinder.
 *  - r: The radius of the cylinder.
 *  - h: The height of the cylinder.
 *  - angle: Degree of rotation.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the cylinder.
 *    - An identifier for material type.
 */
vec2 Cylinder(vec3 p, vec3 c, float r, float h, float angle)
{
    /**
     * TODO: Implement the signed distance function for a cylinder.
     */

    vec3 cp = p - c; // distance from the center of the cylinder to the point
    cp = rotZ(cp, -angle); // rotate the point back around the Z axis
    //vec2(length(cp.xz) = root of x^2 + z^2(ignore y)
    vec2 d = abs(vec2(length(cp.xz), cp.y)) - vec2(r, h * 0.5); // half height of the cylinder, because c is the center of the cylinder
    // d contains the difference between r with cp.xz, and h/2 with cp.y
    vec2 outside = vec2(max(d.x, 0.0), max(d.y, 0.0));
    // d 本身就是差值，取length就是距离,超出部分的距离
    float outsideDist = length(outside);

    // 点在内部时，两者都为负数，insideCandidate为负数，min(insideCandidate, 0.0)为负数
    // 点在外部时，d>0, insideCandidate为正数，min(insideCandidate, 0.0)为0
    float insideCandidate = max(d.x, d.y);
    float insideDist = min(insideCandidate, 0.0);

    // 点在内部时，outsideDist = 0, insideDist < 0, dist = insideDist
    // 点在外部时，outsideDist > 0, insideDist = 0, dist = outsideDist
    // 点在边界时，outsideDist = insideDist = 0, dist = 0
    float dist = outsideDist + insideDist;

    return vec2(dist, 3.0);
}

/*
 * Traingular Prism SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the prism.
 *  - dim: heigh and width of the prism (vec2).
 *  - angle: Degree of rotation.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the prism.
 *    - An identifier for material type.
 */
vec2 TriPrism( vec3 p, vec3 c, vec2 dim, float angle )
{
    /**
     * TODO: Implement the signed distance function for a triangular prism.
     */
    // Triangular prism SDF (Inigo Quilez): triangle in xy, extrusion along z.
    // dim.x = triangle size, dim.y = extrusion length (full). 0.866025 ≈ sqrt(3)/2.
    vec3 cp = p - c; // distance from the center of the prism to the point
    cp = rotZ(cp, angle); // rotate the point back around the Z axis

    vec3 q = abs(cp);
    // formula given in the website(Triangular Prism)
    float d = max(q.z - dim.y * 0.5, max(q.x * 0.866025 + cp.y * 0.5, -cp.y) - dim.x * 0.5);

    return vec2(d, 3.0);
}

/*
 * Rectangular Prism SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the rectangular prism.
 *  - dim: length, height, width of the rectangular prism (vec3).
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the rectangular prism.
 *    - An identifier for material type.
 */
vec2 RectPrism(vec3 p, vec3 c, vec3 dim)
{
    /**
     * TODO: Implement the signed distance function for a rectangular prism.
     */
    vec3 cp = p - c;
    vec3 q = abs(cp) - dim * 0.5; // half the dimensions of the prism
    // formula given in the website(Box)
    float dist = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
    return vec2(dist, 4.0);
}


/*
 * Pumpkin SDF. Centered at PUMPKIN_CENTER.
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the pumpkin.
 *    - An identifier for material type.
 */
vec2 Pumpkin(vec3 p) 
{
    // 南瓜身体：外球
    vec2 body = Sphere(p, PUMPKIN_CENTER, 1.0);
    float d = body.x;

    // 内部挖空：同心内球，形成南瓜壳（空心）
    vec2 innerCavity = Sphere(p, PUMPKIN_CENTER, 0.9);
    d = subtractionSDF(d, innerCavity.x);

    // Part d: 眼睛、鼻子、嘴巴从四周飞入到当前位置的动画（错开时间）
    float tLeft  = min(smoothstep(0.0, 0.9, time), 1.0);
    float tRight = min(smoothstep(0.25, 1.15, time), 1.0);
    float tNose  = min(smoothstep(0.5, 1.4, time), 1.0);
    float tMouth = min(smoothstep(0.75, 1.65, time), 1.0);

    vec3 leftEyeStart  = PUMPKIN_CENTER + vec3(-1.6, 1.25, -0.2);
    vec3 leftEyeEnd    = PUMPKIN_CENTER + vec3(-0.50, 0.25, -1.05);
    vec3 rightEyeStart = PUMPKIN_CENTER + vec3(1.6, 1.25, -0.2);
    vec3 rightEyeEnd   = PUMPKIN_CENTER + vec3(0.50, 0.25, -1.05);
    vec3 noseStart     = PUMPKIN_CENTER + vec3(0.0, 1.4, -0.4);
    vec3 noseEnd       = PUMPKIN_CENTER + vec3(0.0, 0.0, -1.05);
    vec3 mouthStart    = PUMPKIN_CENTER + vec3(0.0, -1.2, -0.78);
    vec3 mouthEnd      = PUMPKIN_CENTER + vec3(0.0, -0.45, -0.78);
    vec3 mStart        = PUMPKIN_CENTER + vec3(0.0, -1.2, -0.85);
    vec3 mEnd          = PUMPKIN_CENTER + vec3(0.0, -0.45, -0.85);

    vec3 leftEyePos  = mix(leftEyeStart, leftEyeEnd, tLeft);
    vec3 rightEyePos = mix(rightEyeStart, rightEyeEnd, tRight);
    vec3 nosePos     = mix(noseStart, noseEnd, tNose);
    vec3 mouthPos    = mix(mouthStart, mouthEnd, tMouth);
    vec3 m           = mix(mStart, mEnd, tMouth);

    // 两个三角形眼睛 + 三角形鼻子：从壳上挖掉
    vec2 leftEye  = TriPrism(p, leftEyePos, vec2(0.29, 1.0), 0.0);
    vec2 rightEye = TriPrism(p, rightEyePos, vec2(0.29, 1.0), 0.0);
    vec2 nose     = TriPrism(p, nosePos, vec2(0.2, 1.0), 0.0);
    vec2 mouth    = RectPrism(p, mouthPos, vec3(0.95, 0.18, 0.35));

    // 嘴巴旁四颗三角形牙齿（随嘴巴一起飞入）
    vec2 tooth1 = TriPrism(p, m + vec3(-0.32, 0.0, 0.0), vec2(0.22, 0.4), 180.0);
    vec2 tooth2 = TriPrism(p, m + vec3(-0.21, 0.0, 0.0), vec2(0.22, 0.4), 0.0);
    vec2 tooth3 = TriPrism(p, m + vec3( 0.21, 0.0, 0.0), vec2(0.22, 0.4), 0.0);
    vec2 tooth4 = TriPrism(p, m + vec3( 0.32, 0.0, 0.0), vec2(0.22, 0.4), 180.0);

    d = subtractionSDF(d, leftEye.x);
    d = subtractionSDF(d, rightEye.x);
    d = subtractionSDF(d, nose.x);
    d = subtractionSDF(d, mouth.x);
    d = subtractionSDF(d, tooth1.x);
    d = subtractionSDF(d, tooth2.x);
    d = subtractionSDF(d, tooth3.x);
    d = subtractionSDF(d, tooth4.x);

    // A stem（作业要求）：顶部圆柱，与身体 union，材质 id 3 = 茎
    vec2 stem = Cylinder(p, PUMPKIN_CENTER + vec3(0.0, 1.05, 0.0), 0.12, 0.2, 0.0);
    float dist = unionSDF(d, stem.x);
    float id = getMaterial(vec2(d, 2.0), stem);  // 2 = 南瓜, 3 = 茎

    return vec2(dist, id);
}

/*
 * Computes the signed distance to the closest surface in the scene.
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the closest material.
 *    - An identifier for the closest material type.
 */
vec2 getSceneDist(vec3 p) {
    
    vec2 pumpkin = Pumpkin(p);
    vec2 plane = Plane(p);
    
    float dist = smoothUnionSDF(pumpkin.x, plane.x, 0.01);
    float id = getMaterial(pumpkin, plane);

    return vec2(dist, id);
}

/*
 * Performs ray marching to determine the closest surface intersection.
 *
 * Parameters:
 *  - ro: Ray origin.
 *  - rd: Ray direction.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Distance to the closest surface intersection.
 *    - material ID of the closest intersected surface.
 */
vec2 rayMarch(vec3 ro, vec3 rd) {
    /**
     * TODO: Implement the ray marching loop for MAX_STEPS.
     *       At each step, use getSceneDist to get the nearest surface distance.
     *       Update the distance and material ID based on the closest surface.
     *       Break if the distance is less than HIT_DIST or the travelled distance is greater than MAX_DIST.
     *       Note, if MAX_DIST is reached, the material ID should be 0.0 (background color).
     */
    float d = 0.0;
    float id = 0.0;

    // based on https://www.youtube.com/watch?v=PGtv-dBi2wE
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d;
        vec2 scene = getSceneDist(p);

        if (scene.x < HIT_DIST) {
            id = scene.y;
            return vec2(d, id);
        }

        d += scene.x;

        if (d > MAX_DIST) {
            return vec2(MAX_DIST, 0.0);
        }
    }

    return vec2(MAX_DIST, 0.0);
}

/* 
 * Helper: computes surface normal
 */
vec3 getNormal(vec3 p) {
	float d = getSceneDist(p).x;
    vec2 e = vec2(.01, 0);
    
    vec3 n = d - vec3(
        getSceneDist(p-e.xyy).x,
        getSceneDist(p-e.yxy).x,
        getSceneDist(p-e.yyx).x);
    
    return normalize(n);
}

/*
 * Helper: gets surface color.
 */
vec3 getColor(vec3 p, float id) 
{
    // Sunset light rotates around the pumpkin based on orbit time (same delay/speed as camera)
    float orbitDelay = 5.0;
    float orbitTime = max(0.0, time - orbitDelay);
    float sunsetRadius = 4.0;
    float sunsetHeight = 4.3;
    float candleRadius = 0.5;
    float candleHeight = 0.2;
    // vec3 lightPos1 = vec3(3, 5, 2); // sunset
    vec3 lightPos1 = PUMPKIN_CENTER + vec3(sunsetRadius * cos(0.8 * orbitTime), sunsetHeight, sunsetRadius * sin(0.8 * orbitTime));

    // Candle light traces a small circle (xz) around a point above pumpkin center
    //vec3 lightPos2 = vec3(0, 1.5, 5); // position candle (centre of pumpkin
    vec3 lightPos2 = PUMPKIN_CENTER + vec3(candleRadius * cos(0.8 * orbitTime), candleHeight, candleRadius * sin(0.8 * orbitTime));

    vec3 l1 = normalize(lightPos1 - p); 
    vec3 l2 = normalize(lightPos2 - p); 
    
    vec3 n = getNormal(p);
    
    // Diffuse terms
    float diffuse1 = clamp(dot(n, l1), 0.2, 1.0);
    float diffuse2 = clamp(dot(n, l2), 0.2, 1.0);

    // Perform shadow check using ray marching 
    { 
        // NOTE: Comment out to improve render performance
        float d1 = rayMarch(p + n * HIT_DIST * 2., l1).x;
        if (d1 < length(lightPos1 - p)) diffuse1 *= 0.1;

        float d2 = rayMarch(p + n * HIT_DIST * 2., l2).x;
        if (d2 < length(lightPos2 - p)) diffuse2 *= 0.1;
    }

    vec3 diffuseColor;

    switch (int(id)) {
        case 0: // background color 
            // should not get here
            break;
        case 1: // grass colour
            diffuseColor = vec3(111,193,45);
            break;
        case 2: // pumpkin body colour
            diffuseColor = vec3(255,103,0);
            break;
        case 3: // stalk colour
            diffuseColor = vec3(136,68,34);
            break;
        default: // background color 
            diffuseColor = vec3(255,147,0);
            break;
    }

    vec3 ambientColor = vec3(.9, .9, .9);
    float ambient = .1;
    
    vec3 lightColorSun = vec3(1.0, 0.55, 0.2);   // warm orange sunset
    vec3 lightColorCandle = vec3(1.0, 0.85, 0.6); // soft candlelight

    vec3 color = ambient * ambientColor
            + diffuse1 * lightColorSun * (diffuseColor / 255.0)
            + diffuse2 * lightColorCandle * (diffuseColor / 255.0);
    return color;
}

/*
 * Helper: camera matrix.
 */
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv =          ( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void main() {
    // Get the fragment coordinate in screen space
    vec2 fragCoord = gl_FragCoord.xy;
    
    // normalize to UV coordinates
    vec2 uv = (fragCoord - 0.5 * resolution.xy) / resolution.y;

    // NOTE: Look-at target (our pumpkin is centered here)
    vec3 ta = PUMPKIN_CENTER; 

    // NOTE: Camera position (you may want to modify this for different views)
    vec3 ro = vec3(0, 2, 0); // static
    // vec3 ro = ta + vec3(4.0 * cos(0.2 * camPos.x), 1.5, 4.0 * sin(0.2 * camPos.x)); // orbit control
    // vec3 ro = ta + vec3(4.0 * cos(0.8 * time), 1.5, 4.0 * sin(0.8 * time)); // orbit time
    // vec3 ro;
    // float orbitDelay = 5.0;
    // float orbitTime = max(0.0, time - orbitDelay);
    // if (orbitTime > 0.0) {
    //     ro = vec3(3.0 * cos(0.8 * orbitTime), 1.5, 2.0 * sin(0.8 * orbitTime));
    // } else {
    //     ro = vec3(0, 2, 0); // static
    // }

    // Compute the camera's coordinate frame (view matrix)
    mat3 ca = setCamera(ro, ta, 0.0); 

    // Compute the ray direction for this pixel with respect ot camera frame
    vec3 rd = ca * normalize(vec3(uv.x, uv.y, 1));

    // Perform ray marching to find intersection distance and surface material ID
    vec2 dist = rayMarch(ro, rd); 
    float d = dist.x; 
    float id = dist.y; 

    // Surface intersection point
    vec3 p = ro + rd * d;

    // Compute surface color
    vec3 color;
    if (id == 0.0) {
        color = vec3(238,64,21) / 255.0; // background color
    } else {
        color = getColor(p, id);
    }

    // Apply gamma correction to adjust brightness (convert from linear to sRGB space)
    color = pow(color, vec3(0.4545)); 

    // Output the final color to the fragment shader
    gl_FragColor = vec4(color, 1.0); 
}

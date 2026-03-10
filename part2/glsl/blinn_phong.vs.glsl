uniform vec3 spherePosition;

// A shared variable is initialized in the vertex shader and attached to the current vertex being processed,
// such that each vertex is given a shared variable and when passed to the fragment shader,
// these values are interpolated between vertices and across fragments,
// below we can see the shared variable is initialized in the vertex shader using the 'out' classifier
out vec3 viewPosition;
out vec3 worldPosition;
out vec3 interpolatedNormal;
out vec3 lightPositionView;

void main() {

    //*====================================(a)====================================*/
    // World space position (for reference; lighting done in view space)
    vec4 worldPos = modelMatrix * vec4(position, 1.0);
    worldPosition = worldPos.xyz; // get world position of the vertex of Snowman

    // View/camera space position (camera at origin)
    vec4 viewPos = viewMatrix * worldPos;
    viewPosition = viewPos.xyz; // get view position of the vertex of Snowman

    // Normal in view space (for consistent lighting with viewPosition)
    interpolatedNormal = normalize(normalMatrix * normal);

    // Light position in view space so fragment shader can compute L without viewMatrix
    vec4 lightPos = viewMatrix * vec4(spherePosition, 1.0);
    lightPositionView = lightPos.xyz; // get light position in view space

    gl_Position = projectionMatrix * viewPos;
    //*====================================(a)====================================*/
}


uniform vec3 ambientColor;
uniform float kAmbient;

uniform vec3 diffuseColor;
uniform float kDiffuse;

uniform vec3 specularColor;
uniform float kSpecular;
uniform float shininess;

uniform mat4 modelMatrix;

uniform vec3 spherePosition;

// The value of our shared variable is given as the interpolation between normals computed in the vertex shader
// below we can see the shared variable we passed from the vertex shader using the 'in' classifier
in vec3 interpolatedNormal;
in vec3 viewPosition;
in vec3 worldPosition;
in vec3 lightPositionView;

void main() {
    //*====================================(a)====================================*/
    // ------------------------------------------------------------
    // Blinn-Phong reflection model (per-fragment lighting)
    //
    // The shader runs in "view space" (camera at origin). The vertex shader
    // already transformed normal and light position into view space and
    // passed them here as interpolated varyings.
    //
    // Definitions (all vectors are normalized to unit length):
    //   N: surface normal
    //   L: direction from the fragment toward the light
    //   V: direction from the fragment toward the camera
    //   H: half-vector between L and V (Blinn-Phong uses H)
    //
    // Main formulas:
    //   ambient  = kAmbient  * ambientColor
    //   diffuse  = kDiffuse  * diffuseColor  * max(dot(N, L), 0)
    //   specular = kSpecular * specularColor * pow(max(dot(N, H), 0), shininess)
    //
    // Notes:
    // - dot(N, L) is proportional to cos(theta) where theta is the angle
    //   between the normal and the light direction.
    // - max(..., 0) prevents negative contributions when the light is behind
    //   the surface.
    // - shininess controls highlight size:
    //     larger shininess  -> smaller/tighter specular highlight
    // ------------------------------------------------------------
    vec3 N = normalize(interpolatedNormal);
    vec3 L = normalize(lightPositionView - viewPosition);
    vec3 V = normalize(-viewPosition);
    vec3 H = normalize(L + V);

    // Ambient + diffuse + specular
    vec3 ambient = kAmbient * ambientColor;
    vec3 diffuse = kDiffuse * diffuseColor * max(dot(N, L), 0.0);
    vec3 specular = kSpecular * specularColor * pow(max(dot(N, H), 0.0), shininess);

    gl_FragColor = vec4(ambient + diffuse + specular, 1.0);
    //*====================================(a)====================================*/
}


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
    // Normal, light direction, view direction (camera at origin in view space)
    vec3 N = normalize(interpolatedNormal);
    vec3 L = normalize(lightPositionView - viewPosition);
    vec3 V = normalize(-viewPosition);
    vec3 H = normalize(L + V);

    // Blinn-Phong: ambient + diffuse + specular
    vec3 ambient = kAmbient * ambientColor;
    vec3 diffuse = kDiffuse * diffuseColor * max(dot(N, L), 0.0);
    vec3 specular = kSpecular * specularColor * pow(max(dot(N, H), 0.0), shininess);

    gl_FragColor = vec4(ambient + diffuse + specular, 1.0);
    //*====================================(a)====================================*/
}

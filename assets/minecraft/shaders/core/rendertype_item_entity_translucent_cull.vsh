#version 150
#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 lightCoord;
out vec3 vNormal;

void main() {
    // ProjMat e ModelViewMat vêm diretamente dos UBOs importados
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    
    vertexColor = Color;
    texCoord0 = UV0;
    
    // Convertendo UV2 (ivec2) para vec2 mapeado entre 0.0 e 1.0 para o .fsh
    lightCoord = vec2(UV2) / 256.0;
    vNormal = Normal;
}
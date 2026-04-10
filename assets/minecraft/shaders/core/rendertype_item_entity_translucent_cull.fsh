#version 150
#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 lightCoord;
in vec3 vNormal;

out vec4 fragColor;

void main() {
    vec4 texColor = texture(Sampler0, texCoord0);
    
    // Detecção precisa da outline baseada no alpha (254)
    ivec4 ich = ivec4(round(
        texelFetch(Sampler0, ivec2(texCoord0 * textureSize(Sampler0, 0)), 0) * 255.0
    ));
    bool isOutline = (ich.a == 254);

    // Se estiver vazio e não for outline, descarta imediatamente
    if (texColor.a < 0.1 && !isOutline) discard;

    vec4 finalLight;
    if (isOutline) {
        // Brilho MÁXIMO e ZERO sombra:
        // Ignora totalmente o lightmap (Sampler2) e as luzes direcionais do mundo.
        finalLight = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        // Item Normal: Combina a luz direcional (relevo) com o lightmap (ambiente)
        finalLight = minecraft_mix_light(Light0_Direction, Light1_Direction, vNormal, vec4(1.0)) * texture(Sampler2, lightCoord);
    }

    // Aplica a cor da textura, a cor do vértice (tint), o ColorModulator e a nossa luz calculada
    vec4 color = texColor * vertexColor * ColorModulator * finalLight;
    
    // Garantia final de transparência
    if (color.a < 0.1) discard;

    fragColor = apply_fog(
        color,
        sphericalVertexDistance,
        cylindricalVertexDistance,
        FogEnvironmentalStart,
        FogEnvironmentalEnd,
        FogRenderDistanceStart,
        FogRenderDistanceEnd,
        FogColor
    );
}
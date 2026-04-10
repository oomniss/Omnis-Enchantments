#version 150
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 texColor = texture(Sampler0, texCoord0);

    // Lê o pixel como inteiros exatos (0–255) para detecção precisa de alpha
    ivec4 ich = ivec4(round(
        texelFetch(Sampler0, ivec2(texCoord0 * textureSize(Sampler0, 0)), 0) * 255.0
    ));

    // Outline: qualquer pixel da outline.png tem alpha = 254
    bool isOutline = ich.a == 254;

    if (texColor.a < 0.1 && !isOutline) discard;

    vec4 color;
    if (isOutline) {
        // Cor pura da textura sem iluminação direcional
        color = vec4(texColor.rgb * ColorModulator.rgb, 1.0);
    } else {
        // Iluminação normal do Minecraft
        color = texColor * vertexColor * ColorModulator;
        if (color.a < 0.1) discard;
    }

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
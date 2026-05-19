#version 150
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 texColor = textureLod(Sampler0, texCoord0, 0.0);

    ivec2 texelCoord = ivec2(round(texCoord0 * vec2(textureSize(Sampler0, 0)) - 0.5));
    ivec4 ich = ivec4(texelFetch(Sampler0, texelCoord, 0) * 255.0 + 0.5);

    bool isOutline      = ich.a == 254;
    bool isEmissiveFlag = texelFetch(Sampler1, ivec2(0, 0), 0).a > 0.5;
    bool isEmissive     = isEmissiveFlag && (ich.a == 253);

    if (texColor.a < 0.1 && !isOutline) discard;

    vec4 color;
    if (isOutline) {
        color = vec4(texColor.rgb * ColorModulator.rgb, 1.0);
    } else if (isEmissive) {
        color = vec4(texColor.rgb * vertexColor.rgb * ColorModulator.rgb, texColor.a * ColorModulator.a);
        if (color.a < 0.1) discard;
    } else {
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
#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 vertexColorNoDirectional;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

void main() {
    vec4 texColor = texture(Sampler0, texCoord0);
    int alpha = int(round(texColor.a * 255.0));
    bool isOutline = alpha == 254;
    bool isEmissive = alpha == 253;

    if (texColor.a < 0.1 && !isOutline) {
        discard;
    }

    vec4 color;
    if (isOutline) {
        color = vec4(texColor.rgb * ColorModulator.rgb, 1.0);
    } else if (isEmissive) {
        color = vec4(texColor.rgb * vertexColorNoDirectional.rgb * ColorModulator.rgb, texColor.a * ColorModulator.a);
    } else {
        color = texColor * vertexColor * ColorModulator;
    }

    if (color.a < 0.1) {
        discard;
    }

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}

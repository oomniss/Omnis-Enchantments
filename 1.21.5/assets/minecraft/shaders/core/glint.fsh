#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform float GlintAlpha;

in float vertexDistance;
in vec2 texCoord0;
in float glintTime;

out vec4 fragColor;

const float SATURATION = 2.0;
const float BRIGHTNESS = 1.1;
const float PULSE_AMP = 0.1;
const float PULSE_FREQ = 4.0;

vec3 boostSaturation(vec3 color, float factor) {
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luma), color, factor);
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }

    float fade = linear_fog_fade(vertexDistance, FogStart, FogEnd) * GlintAlpha;
    color.rgb = boostSaturation(color.rgb, SATURATION) * BRIGHTNESS;
    color.rgb *= 1.0 - PULSE_AMP + PULSE_AMP * sin(glintTime * PULSE_FREQ);
    color.rgb = min(color.rgb, vec3(1.0));

    fragColor = vec4(color.rgb * fade, color.a);
}

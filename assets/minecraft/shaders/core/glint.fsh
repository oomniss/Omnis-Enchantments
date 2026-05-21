#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec2 texCoord0;

// Recebido do vertex shader para pulsação baseada em tempo real
in float glintTime;

out vec4 fragColor;

// ─── Configurações do glint Ominis ─────────────────────────────────────────

// Saturação: 1.0 = original, 3.0+ = cores vívidas
const float SATURATION = 2.0;

// Brilho base após saturação
const float BRIGHTNESS = 1.1;

// Pulsação: amplitude (0.0 = sem pulso, 0.25 = suave)
const float PULSE_AMP  = 0.1;

// Pulsação: frequência (ciclos por unidade de TextureMat time)
const float PULSE_FREQ = 7.0;

// ───────────────────────────────────────────────────────────────────────────

vec3 boostSaturation(vec3 color, float factor) {
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luma), color, factor);
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;

    if (color.a < 0.1) discard;

    // Fade de distância (vanilla preservado)
    float fade = (1.0 - total_fog_value(
        sphericalVertexDistance,
        cylindricalVertexDistance,
        FogEnvironmentalStart,
        FogEnvironmentalEnd,
        FogRenderDistanceStart,
        FogRenderDistanceEnd
    )) * GlintAlpha;

    // 1. Saturação
    color.rgb = boostSaturation(color.rgb, SATURATION);

    // 2. Brilho base
    color.rgb *= BRIGHTNESS;

    // 3. Pulsação — glintTime vem do vsh via texCoord animado pelo TextureMat
    float pulse = 1.0 - PULSE_AMP + PULSE_AMP * sin(glintTime * PULSE_FREQ);
    color.rgb *= pulse;

    // 4. Clamp SDR
    color.rgb = min(color.rgb, vec3(1.0));

    fragColor = vec4(color.rgb * fade, color.a);
}
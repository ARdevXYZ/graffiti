#include "graffiti/SprayBrush.hpp"

#include <algorithm>
#include <cmath>

namespace graffiti {

namespace {
constexpr int kRadiusPx = 28;
constexpr int kDotsPerTick = 320;
constexpr float kDotAlpha = 0.22f;
}

SprayBrush::SprayBrush() : m_state(0xA341316Cu) {}

uint32_t SprayBrush::nextU32() {
    uint32_t x = m_state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    m_state = x;
    return x;
}

float SprayBrush::nextFloat() {
    return static_cast<float>(nextU32() & 0x00FFFFFF) / static_cast<float>(0x01000000);
}

void SprayBrush::spray(Bitmap& target, int cx, int cy, const Color& color) {
    const int radius = kRadiusPx;
    const float baseAlpha = kDotAlpha * 255.0f;

    for (int i = 0; i < kDotsPerTick; ++i) {
        const float u = nextFloat();
        const float v = nextFloat();
        const float angle = u * 6.2831853f;
        const float dist = std::sqrt(v) * radius;

        const int x = static_cast<int>(std::round(cx + std::cos(angle) * dist));
        const int y = static_cast<int>(std::round(cy + std::sin(angle) * dist));

        const float falloff = 1.0f - (dist / static_cast<float>(radius));
        const uint8_t a = static_cast<uint8_t>(std::clamp(baseAlpha * falloff, 0.0f, 255.0f));

        target.alphaBlendPixel(x, y, color.r, color.g, color.b, a);
    }
}

} // namespace graffiti

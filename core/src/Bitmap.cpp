#include "graffiti/Bitmap.hpp"

#include <algorithm>
#include <cstring>

namespace graffiti {

Bitmap::Bitmap() = default;

Bitmap::Bitmap(int w, int h) {
    resize(w, h);
}

void Bitmap::resize(int w, int h) {
    m_width = std::max(0, w);
    m_height = std::max(0, h);
    m_pixels.assign(static_cast<size_t>(m_width * m_height * 4), 0);
}

void Bitmap::clearTransparent() {
    std::fill(m_pixels.begin(), m_pixels.end(), 0);
}

void Bitmap::alphaBlendPixel(int x, int y, uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
    if (x < 0 || y < 0 || x >= m_width || y >= m_height) {
        return;
    }
    if (a == 0) {
        return;
    }

    const float alpha = static_cast<float>(a) / 255.0f;
    const float inv = 1.0f - alpha;

    const size_t idx = static_cast<size_t>((y * m_width + x) * 4);
    uint8_t* p = &m_pixels[idx];

    p[0] = static_cast<uint8_t>(std::clamp(static_cast<int>(r * alpha + p[0] * inv), 0, 255));
    p[1] = static_cast<uint8_t>(std::clamp(static_cast<int>(g * alpha + p[1] * inv), 0, 255));
    p[2] = static_cast<uint8_t>(std::clamp(static_cast<int>(b * alpha + p[2] * inv), 0, 255));
    p[3] = static_cast<uint8_t>(std::clamp(static_cast<int>(a + p[3] * inv), 0, 255));
}

} // namespace graffiti

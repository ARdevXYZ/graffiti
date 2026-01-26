#pragma once

#include <cstdint>
#include <vector>

namespace graffiti {

class Bitmap {
public:
    Bitmap();
    Bitmap(int w, int h);

    int width() const { return m_width; }
    int height() const { return m_height; }

    uint8_t* data() { return m_pixels.data(); }
    const uint8_t* data() const { return m_pixels.data(); }

    void resize(int w, int h);
    void clearTransparent();

    void alphaBlendPixel(int x, int y, uint8_t r, uint8_t g, uint8_t b, uint8_t a);

private:
    int m_width = 0;
    int m_height = 0;
    std::vector<uint8_t> m_pixels; // RGBA8
};

} // namespace graffiti

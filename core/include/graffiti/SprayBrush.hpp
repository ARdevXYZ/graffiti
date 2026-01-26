#pragma once

#include <cstdint>

#include "graffiti/Bitmap.hpp"

namespace graffiti {

struct Color {
    uint8_t r;
    uint8_t g;
    uint8_t b;
};

class SprayBrush {
public:
    SprayBrush();

    void spray(Bitmap& target, int cx, int cy, const Color& color);

private:
    uint32_t m_state;

    uint32_t nextU32();
    float nextFloat();
};

} // namespace graffiti

#include "graffiti/CanvasModel.hpp"

#include <algorithm>
#include <cstring>

namespace graffiti {

CanvasModel::CanvasModel() : m_undo(20) {}

void CanvasModel::setBackgroundRGBA(const uint8_t* rgba, int w, int h) {
    if (!rgba || w <= 0 || h <= 0) {
        return;
    }
    m_background.resize(w, h);
    m_paint.resize(w, h);
    m_composite.resize(w, h);

    std::memcpy(m_background.data(), rgba, static_cast<size_t>(w * h * 4));
    m_paint.clearTransparent();
    m_dirty = true;
    m_undo.clear();
}

void CanvasModel::setColor(ColorId color) {
    m_color = color;
}

void CanvasModel::beginStroke() {
    if (m_strokeActive) {
        return;
    }
    m_undo.push(m_paint);
    m_strokeActive = true;
}

void CanvasModel::tickSpray(int x, int y) {
    if (!m_strokeActive) {
        return;
    }
    m_brush.spray(m_paint, x, y, currentColor());
    m_dirty = true;
}

void CanvasModel::endStroke() {
    m_strokeActive = false;
}

void CanvasModel::undo() {
    Bitmap snapshot;
    if (m_undo.pop(snapshot)) {
        m_paint = snapshot;
        m_dirty = true;
    }
}

void CanvasModel::clearPaint() {
    m_paint.clearTransparent();
    m_undo.clear();
    m_dirty = true;
}

const uint8_t* CanvasModel::getCompositeRGBA(int& outW, int& outH) {
    outW = m_background.width();
    outH = m_background.height();
    if (m_dirty) {
        rebuildComposite();
    }
    return m_composite.data();
}

void CanvasModel::rebuildComposite() {
    const int w = m_background.width();
    const int h = m_background.height();
    if (w == 0 || h == 0) {
        m_dirty = false;
        return;
    }

    std::memcpy(m_composite.data(), m_background.data(), static_cast<size_t>(w * h * 4));

    const uint8_t* paint = m_paint.data();
    uint8_t* dst = m_composite.data();
    const size_t pixelCount = static_cast<size_t>(w * h);

    for (size_t i = 0; i < pixelCount; ++i) {
        const uint8_t pr = paint[i * 4 + 0];
        const uint8_t pg = paint[i * 4 + 1];
        const uint8_t pb = paint[i * 4 + 2];
        const uint8_t pa = paint[i * 4 + 3];
        if (pa == 0) {
            continue;
        }

        const float alpha = static_cast<float>(pa) / 255.0f;
        const float inv = 1.0f - alpha;

        // Paint layer is stored premultiplied, so don't multiply color by alpha again.
        dst[i * 4 + 0] = static_cast<uint8_t>(std::clamp(static_cast<int>(pr + dst[i * 4 + 0] * inv), 0, 255));
        dst[i * 4 + 1] = static_cast<uint8_t>(std::clamp(static_cast<int>(pg + dst[i * 4 + 1] * inv), 0, 255));
        dst[i * 4 + 2] = static_cast<uint8_t>(std::clamp(static_cast<int>(pb + dst[i * 4 + 2] * inv), 0, 255));
        dst[i * 4 + 3] = 255;
    }

    m_dirty = false;
}

Color CanvasModel::currentColor() const {
    switch (m_color) {
        case ColorId::White:
            return {255, 255, 255};
        case ColorId::Yellow:
            return {255, 255, 0};
        case ColorId::Green:
            return {0, 255, 0};
        case ColorId::Pink:
            return {255, 105, 180};
    }
    return {255, 255, 255};
}

} // namespace graffiti

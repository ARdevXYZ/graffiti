#pragma once

#include <cstdint>

#include "graffiti/Bitmap.hpp"
#include "graffiti/SprayBrush.hpp"
#include "graffiti/UndoStack.hpp"

namespace graffiti {

class CanvasModel {
public:
    enum class ColorId {
        White,
        Red,
        Green,
        Blue
    };

    CanvasModel();

    void setBackgroundRGBA(const uint8_t* rgba, int w, int h);
    void setColor(ColorId color);

    void beginStroke();
    void tickSpray(int x, int y);
    void endStroke();

    void undo();
    void clearPaint();

    const uint8_t* getCompositeRGBA(int& outW, int& outH);

private:
    void rebuildComposite();
    Color currentColor() const;

    Bitmap m_background;
    Bitmap m_paint;
    Bitmap m_composite;

    ColorId m_color = ColorId::White;
    bool m_dirty = true;

    SprayBrush m_brush;
    UndoStack m_undo;
    bool m_strokeActive = false;
};

} // namespace graffiti

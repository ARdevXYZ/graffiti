#pragma once

#include <vector>

#include "graffiti/Bitmap.hpp"

namespace graffiti {

class UndoStack {
public:
    explicit UndoStack(size_t maxSize = 20);

    void push(const Bitmap& snapshot);
    bool pop(Bitmap& out);
    void clear();

private:
    size_t m_maxSize;
    std::vector<Bitmap> m_stack;
};

} // namespace graffiti

#include "graffiti/UndoStack.hpp"

namespace graffiti {

UndoStack::UndoStack(size_t maxSize) : m_maxSize(maxSize) {}

void UndoStack::push(const Bitmap& snapshot) {
    if (m_stack.size() >= m_maxSize) {
        m_stack.erase(m_stack.begin());
    }
    m_stack.push_back(snapshot);
}

bool UndoStack::pop(Bitmap& out) {
    if (m_stack.empty()) {
        return false;
    }
    out = m_stack.back();
    m_stack.pop_back();
    return true;
}

void UndoStack::clear() {
    m_stack.clear();
}

} // namespace graffiti

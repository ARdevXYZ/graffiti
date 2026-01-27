#import "CoreBridge.h"

#include <memory>

#include "graffiti/CanvasModel.hpp"

using graffiti::CanvasModel;

@interface CoreBridge ()
@end

@implementation CoreBridge {
    std::unique_ptr<CanvasModel> _model;
    int _width;
    int _height;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _model = std::make_unique<CanvasModel>();
        _width = 0;
        _height = 0;
    }
    return self;
}

- (void)setBackgroundRGBA:(const uint8_t *)rgba width:(NSInteger)width height:(NSInteger)height {
    if (!rgba || width <= 0 || height <= 0) {
        return;
    }
    _model->setBackgroundRGBA(rgba, (int)width, (int)height);
    _width = (int)width;
    _height = (int)height;
}

- (void)setColorIndex:(NSInteger)index {
    CanvasModel::ColorId color = CanvasModel::ColorId::White;
    switch (index) {
        case 1:
            color = CanvasModel::ColorId::Yellow;
            break;
        case 2:
            color = CanvasModel::ColorId::Green;
            break;
        case 3:
            color = CanvasModel::ColorId::Pink;
            break;
        default:
            color = CanvasModel::ColorId::White;
            break;
    }
    _model->setColor(color);
}

- (void)beginStroke {
    _model->beginStroke();
}

- (void)tickSprayAtX:(NSInteger)x y:(NSInteger)y {
    _model->tickSpray((int)x, (int)y);
}

- (void)endStroke {
    _model->endStroke();
}

- (void)undo {
    _model->undo();
}

- (void)clearPaint {
    _model->clearPaint();
}

- (const uint8_t *)compositeBytes {
    int w = 0;
    int h = 0;
    const uint8_t *bytes = _model->getCompositeRGBA(w, h);
    _width = w;
    _height = h;
    return bytes;
}

- (NSInteger)width {
    return _width;
}

- (NSInteger)height {
    return _height;
}

@end

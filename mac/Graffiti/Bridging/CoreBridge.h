#import <Foundation/Foundation.h>
#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreBridge : NSObject

- (instancetype)init;

- (void)setBackgroundRGBA:(const uint8_t *)rgba width:(NSInteger)width height:(NSInteger)height;
- (void)setColorIndex:(NSInteger)index;

- (void)beginStroke;
- (void)tickSprayAtX:(NSInteger)x y:(NSInteger)y;
- (void)endStroke;

- (void)undo;
- (void)clearPaint;

- (const uint8_t *)compositeBytes;
- (NSInteger)width;
- (NSInteger)height;

@end

NS_ASSUME_NONNULL_END

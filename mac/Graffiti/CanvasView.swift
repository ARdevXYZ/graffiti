import AppKit

final class CanvasView: NSView {
    private let core: CoreBridge
    private var sprayTimer: Timer?
    private var cursorLocation: NSPoint = .zero
    private var isSpraying = false
    private var debugCursor = false
    private lazy var sprayCursor: NSCursor = Self.makeSprayCursor()

    var onExport: (() -> Void)?
    var onUndo: (() -> Void)?
    var onClear: (() -> Void)?
    var onColorChange: ((Int) -> Void)?

    init(core: CoreBridge) {
        self.core = core
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }
    override var isFlipped: Bool { true }

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: sprayCursor)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.invalidateCursorRects(for: self)
    }

    func refresh() {
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let image = currentCGImage() else { return }
        NSGraphicsContext.current?.imageInterpolation = .none
        let boundsRect = bounds
        NSColor.black.setFill()
        boundsRect.fill()
        NSGraphicsContext.current?.cgContext.draw(image, in: canvasRectCover(for: CGSize(width: image.width, height: image.height),
                                                                            in: boundsRect))
        if debugCursor {
            NSColor.magenta.setFill()
            let dot = NSRect(x: cursorLocation.x - 2, y: cursorLocation.y - 2, width: 4, height: 4)
            dot.fill()
        }
    }

    func currentCGImage() -> CGImage? {
        let bytes = core.compositeBytes()
        let width = core.width()
        let height = core.height()
        if width <= 0 || height <= 0 {
            return nil
        }
        let byteCount = width * height * 4
        let data = Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: bytes), count: byteCount, deallocator: .none)
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        return CGImage(width: width,
                       height: height,
                       bitsPerComponent: 8,
                       bitsPerPixel: 32,
                       bytesPerRow: width * 4,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)
    }

    func exportCGImage() -> CGImage? {
        guard let image = currentCGImage() else { return nil }
        let exportWidth = core.width() * 2
        let exportHeight = core.height() * 2
        if exportWidth <= 0 || exportHeight <= 0 {
            return image
        }
        guard let context = CGContext(data: nil,
                                      width: exportWidth,
                                      height: exportHeight,
                                      bitsPerComponent: 8,
                                      bytesPerRow: exportWidth * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return image
        }
        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: exportWidth, height: exportHeight))
        let rect = canvasRectCover(for: CGSize(width: image.width, height: image.height),
                                   in: CGRect(x: 0, y: 0, width: exportWidth, height: exportHeight))
        context.interpolationQuality = .none
        context.draw(image, in: rect)
        return context.makeImage()
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        cursorLocation = convert(event.locationInWindow, from: nil)
        core.beginStroke()
        isSpraying = true
        sprayTick()
        needsDisplay = true
        startTimer()
    }

    override func mouseDragged(with event: NSEvent) {
        cursorLocation = convert(event.locationInWindow, from: nil)
        sprayTick()
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        cursorLocation = convert(event.locationInWindow, from: nil)
        sprayTick()
        needsDisplay = true
        stopTimer()
        core.endStroke()
        isSpraying = false
    }

    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.command) {
            let key = event.charactersIgnoringModifiers ?? ""
            switch key.lowercased() {
            case "z":
                onUndo?()
            case "n":
                onClear?()
            case "e":
                onExport?()
            default:
                break
            }
            return
        }

        guard let key = event.charactersIgnoringModifiers else { return }
        switch key {
        case "1":
            core.setColorIndex(0)
            onColorChange?(0)
        case "2":
            core.setColorIndex(1)
            onColorChange?(1)
        case "3":
            core.setColorIndex(2)
            onColorChange?(2)
        case "4":
            core.setColorIndex(3)
            onColorChange?(3)
        default:
            break
        }
    }

    private func startTimer() {
        if sprayTimer != nil { return }
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.sprayTick()
        }
        timer.tolerance = 1.0 / 240.0
        RunLoop.main.add(timer, forMode: .common)
        sprayTimer = timer
    }

    private func stopTimer() {
        sprayTimer?.invalidate()
        sprayTimer = nil
    }

    private func sprayTick() {
        guard isSpraying else { return }
        let mapped = mapPointToCanvas(cursorLocation)
        core.tickSprayAt(x: mapped.x, y: mapped.y)
        needsDisplay = true
    }

    private func mapPointToCanvas(_ point: NSPoint) -> (x: Int, y: Int) {
        let w = CGFloat(core.width())
        let h = CGFloat(core.height())
        if w <= 0 || h <= 0 || bounds.width <= 0 || bounds.height <= 0 {
            return (0, 0)
        }
        let rect = canvasRectCover(for: CGSize(width: w, height: h), in: bounds)
        let clampedX = min(max(point.x, rect.minX), rect.maxX)
        let clampedY = min(max(point.y, rect.minY), rect.maxY)
        let nx = (clampedX - rect.minX) / rect.width
        let ny = (clampedY - rect.minY) / rect.height
        return (Int(nx * w), Int(ny * h))
    }

    private func canvasRectCover(for size: CGSize, in boundsRect: NSRect) -> NSRect {
        if size.width <= 0 || size.height <= 0 || boundsRect.width <= 0 || boundsRect.height <= 0 {
            return boundsRect
        }
        let scale = max(boundsRect.width / size.width, boundsRect.height / size.height)
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(x: (boundsRect.width - scaledSize.width) * 0.5,
                             y: (boundsRect.height - scaledSize.height) * 0.5)
        return NSRect(origin: origin, size: scaledSize)
    }

    private static func makeSprayCursor() -> NSCursor {
        let bundleURL =
            Bundle.main.url(forResource: "icons8-spray-can-48", withExtension: "png", subdirectory: "cursor") ??
            Bundle.main.url(forResource: "icons8-spray-can-48", withExtension: "png")
        let image =
            NSImage(named: "icons8-spray-can-48") ??
            bundleURL.flatMap(NSImage.init(contentsOf:))

        guard let image else {
            NSLog("[Cursor] Missing bundled file: Resources/cursor/icons8-spray-can-48.png")
            return .arrow
        }

        // Bias the hotspot toward the can nozzle so paint lands near the visible tip.
        let hotSpot = NSPoint(x: min(12, image.size.width - 1), y: max(0, image.size.height - 10))
        return NSCursor(image: image, hotSpot: hotSpot)
    }
}

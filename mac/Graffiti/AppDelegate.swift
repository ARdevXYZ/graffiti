import AppKit
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let core = CoreBridge()
    private var window: NSWindow?
    private var canvasView: CanvasView?
    private var toolbarController: ToolbarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.mainMenu = buildMainMenu()

        guard let (rgba, width, height) = loadBrickwall() else {
            fatalError("Failed to load brickwall.png")
        }
        rgba.withUnsafeBytes { bytes in
            core.setBackgroundRGBA(bytes.bindMemory(to: UInt8.self).baseAddress!, width: width, height: height)
        }

        let canvas = CanvasView(core: core)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvasView = canvas

        let toolbar = ToolbarController()
        toolbarController = toolbar

        toolbar.colorControl.target = self
        toolbar.colorControl.action = #selector(colorChanged(_:))
        toolbar.exportButton.target = self
        toolbar.exportButton.action = #selector(exportPNG(_:))
        toolbar.undoButton.target = self
        toolbar.undoButton.action = #selector(undoAction(_:))

        canvas.onExport = { [weak self] in self?.exportPNG(nil) }
        canvas.onUndo = { [weak self] in self?.undoAction(nil) }
        canvas.onClear = { [weak self] in self?.clearCanvas(nil) }
        canvas.onColorChange = { [weak self] index in
            self?.toolbarController?.colorControl.selectedSegment = index
        }

        let windowRect = NSRect(x: 0, y: 0, width: CGFloat(width * 2), height: CGFloat(height * 2 + 44))
        let rootView = NSView(frame: NSRect(origin: .zero, size: windowRect.size))
        rootView.autoresizingMask = [.width, .height]

        rootView.addSubview(toolbar.containerView)
        rootView.addSubview(canvas)

        NSLayoutConstraint.activate([
            toolbar.containerView.topAnchor.constraint(equalTo: rootView.topAnchor),
            toolbar.containerView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            toolbar.containerView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            toolbar.containerView.heightAnchor.constraint(equalToConstant: 44),

            canvas.topAnchor.constraint(equalTo: toolbar.containerView.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            canvas.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
        ])

        let window = NSWindow(contentRect: windowRect,
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered,
                              defer: false)
        window.title = "G R A F F I T I"
        window.contentView = rootView
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(canvas)
        window.isReleasedWhenClosed = false
        self.window = window

        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @objc private func colorChanged(_ sender: NSSegmentedControl) {
        core.setColorIndex(sender.selectedSegment)
    }

    @objc private func exportPNG(_ sender: Any?) {
        guard let canvas = canvasView, let image = canvas.exportCGImage() else {
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.png]
        panel.nameFieldStringValue = "Graffiti.png"
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
                return
            }
            CGImageDestinationAddImage(destination, image, nil)
            CGImageDestinationFinalize(destination)
        }
    }

    @objc private func undoAction(_ sender: Any?) {
        core.undo()
        canvasView?.refresh()
    }

    @objc private func clearCanvas(_ sender: Any?) {
        core.clearPaint()
        canvasView?.refresh()
    }

    private func loadBrickwall() -> (Data, Int, Int)? {
        guard let url = Bundle.main.url(forResource: "brickwall", withExtension: "png"),
              let image = NSImage(contentsOf: url) else {
            return nil
        }
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var buffer = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(data: &buffer,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (Data(buffer), width, height)
    }

    private func buildMainMenu() -> NSMenu {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit Graffiti", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu

        return mainMenu
    }
}

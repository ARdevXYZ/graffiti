import AppKit

final class ToolbarController {
    let containerView: NSView
    let colorControl: NSSegmentedControl
    let exportButton: NSButton
    let undoButton: NSButton

    init() {
        containerView = NSView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 1.0).cgColor

        colorControl = NSSegmentedControl(labels: ["W", "R", "G", "B"], trackingMode: .selectOne, target: nil, action: nil)
        colorControl.selectedSegment = 0
        colorControl.segmentStyle = .texturedRounded
        colorControl.translatesAutoresizingMaskIntoConstraints = false

        exportButton = NSButton(title: "EXPORT", target: nil, action: nil)
        exportButton.bezelStyle = .texturedRounded
        exportButton.translatesAutoresizingMaskIntoConstraints = false

        undoButton = NSButton(title: "UNDO", target: nil, action: nil)
        undoButton.bezelStyle = .texturedRounded
        undoButton.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(colorControl)
        containerView.addSubview(exportButton)
        containerView.addSubview(undoButton)

        NSLayoutConstraint.activate([
            colorControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            colorControl.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            undoButton.trailingAnchor.constraint(equalTo: exportButton.leadingAnchor, constant: -8),
            undoButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            exportButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            exportButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}

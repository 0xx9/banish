#!/usr/bin/env swift
import AppKit

let output = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "build/AppIcon.iconset")
let sizes = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

for (name, pixels) in sizes {
    guard let png = render(pixels: pixels) else {
        fputs("Could not render \(name)\n", stderr)
        exit(1)
    }
    try png.write(to: output.appendingPathComponent(name))
}

func render(pixels: Int) -> Data? {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { return nil }

    rep.size = NSSize(width: pixels, height: pixels)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: pixels, height: pixels).fill()
    drawIcon(pixels: pixels)
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

func drawIcon(pixels: Int) {
    let side = CGFloat(pixels)
    let inset = side * 0.06
    let rect = NSRect(x: inset, y: inset, width: side - inset * 2, height: side - inset * 2)
    let radius = rect.width * 0.225
    let shape = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    let gradient = NSGradient(colors: [
        NSColor(srgbRed: 0.27, green: 0.48, blue: 0.98, alpha: 1),
        NSColor(srgbRed: 0.02, green: 0.66, blue: 0.64, alpha: 1)
    ])
    gradient?.draw(in: shape, angle: -50)

    shape.addClip()
    let gloss = NSBezierPath(ovalIn: NSRect(x: rect.minX - rect.width * 0.1, y: rect.midY, width: rect.width * 1.2, height: rect.height * 0.9))
    NSColor(calibratedWhite: 1, alpha: 0.16).setFill()
    gloss.fill()

    NSColor.white.setFill()
    sparkle(
        center: CGPoint(x: rect.midX, y: rect.midY - side * 0.01),
        outer: side * 0.20,
        inner: side * 0.045
    ).fill()
    sparkle(
        center: CGPoint(x: rect.midX + side * 0.16, y: rect.midY + side * 0.15),
        outer: side * 0.075,
        inner: side * 0.018
    ).fill()
}

func sparkle(center: CGPoint, outer: CGFloat, inner: CGFloat) -> NSBezierPath {
    let path = NSBezierPath()
    let points = 4
    var vertices: [CGPoint] = []
    for index in 0..<(points * 2) {
        let radius = index.isMultiple(of: 2) ? outer : inner
        let angle = CGFloat(index) * .pi / CGFloat(points) - .pi / 2
        vertices.append(CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius))
    }
    path.move(to: vertices[0])
    for point in vertices.dropFirst() {
        path.line(to: point)
    }
    path.close()
    return path
}

import AppKit

let S: CGFloat = 1024

struct Variant { let name: String; let c0: NSColor; let c1: NSColor; let bolt: NSColor; let dark: Bool }
func rgb(_ r: CGFloat,_ g: CGFloat,_ b: CGFloat) -> NSColor { NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: 1) }

let variants = [
  Variant(name: "A_blue_violet", c0: rgb(80,124,255),  c1: rgb(108,44,245),  bolt: .white,            dark: false),
  Variant(name: "B_amber_black", c0: rgb(255,190,32),  c1: rgb(255,120,0),   bolt: rgb(24,24,28),     dark: false),
  Variant(name: "C_dark_yellow", c0: rgb(38,38,58),    c1: rgb(20,20,32),    bolt: rgb(255,210,63),   dark: true),
]

func render(_ v: Variant) {
  let img = NSImage(size: NSSize(width: S, height: S))
  img.lockFocus()
  let ctx = NSGraphicsContext.current!.cgContext

  let margin: CGFloat = 100
  let body = CGRect(x: margin, y: margin, width: S - 2*margin, height: S - 2*margin)
  let radius = body.width * 0.2237
  let path = CGPath(roundedRect: body, cornerWidth: radius, cornerHeight: radius, transform: nil)

  // drop shadow behind the squircle
  ctx.saveGState()
  ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 44,
                color: NSColor.black.withAlphaComponent(0.30).cgColor)
  ctx.addPath(path); ctx.setFillColor(v.c1.cgColor); ctx.fillPath()
  ctx.restoreGState()

  // gradient body
  ctx.saveGState(); ctx.addPath(path); ctx.clip()
  let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                        colors: [v.c0.cgColor, v.c1.cgColor] as CFArray, locations: [0,1])!
  ctx.drawLinearGradient(grad, start: CGPoint(x: body.minX, y: body.maxY),
                         end: CGPoint(x: body.maxX, y: body.minY), options: [])
  // top sheen
  let sheen = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [NSColor.white.withAlphaComponent(v.dark ? 0.10 : 0.22).cgColor,
             NSColor.white.withAlphaComponent(0).cgColor] as CFArray, locations: [0,1])!
  ctx.drawLinearGradient(sheen, start: CGPoint(x: body.midX, y: body.maxY),
                         end: CGPoint(x: body.midX, y: body.midY), options: [])
  ctx.restoreGState()

  // lightning bolt (SF Symbol), centered
  let cfg = NSImage.SymbolConfiguration(pointSize: 600, weight: .bold)
              .applying(.init(paletteColors: [v.bolt]))
  if let bolt = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: nil)?
                  .withSymbolConfiguration(cfg) {
    let bs = bolt.size
    ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 22,
                  color: NSColor.black.withAlphaComponent(v.dark ? 0.55 : 0.22).cgColor)
    bolt.draw(at: NSPoint(x: (S-bs.width)/2, y: (S-bs.height)/2),
              from: .zero, operation: .sourceOver, fraction: 1)
  }
  img.unlockFocus()

  let png = NSBitmapImageRep(data: img.tiffRepresentation!)!.representation(using: .png, properties: [:])!
  try! png.write(to: URL(fileURLWithPath: "/tmp/fasticon/\(v.name).png"))
  print("wrote \(v.name).png")
}
variants.forEach(render)

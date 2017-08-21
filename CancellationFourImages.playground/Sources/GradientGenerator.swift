import UIKit

public func topAndBottomGradient(_ size: CGSize, clearLocations: [CGFloat] = [0.4, 0.6], innerIntensity: CGFloat = 0.5) -> UIImage {
    
    let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)
    
    let colors = [
        UIColor.white,
        UIColor(white: innerIntensity, alpha: 1.0),
        UIColor.black,
        UIColor(white: innerIntensity, alpha: 1.0),
        UIColor.white
        ].map { $0.cgColor }
    let colorLocations : [CGFloat] = [0, clearLocations[0], (clearLocations[0] + clearLocations[1]) / 2.0, clearLocations[1], 1]
    
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceGray(), colors: colors as CFArray, locations: colorLocations)
    
    let startPoint = CGPoint(x: 0, y: 0)
    let endPoint = CGPoint(x: 0, y: size.height)
    context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions())
    
    let cgImage = context?.makeImage()
    
    return UIImage(cgImage: cgImage!)
}



import CoreImage
import UIKit
import Vision

/// Decodes a QR code payload from a static `UIImage` (gallery, Files). Uses Vision with `CIDetector` fallback.
enum QRCodeImageScanner {
    static func detectString(in image: UIImage) -> String? {
        guard image.size.width > 0, image.size.height > 0 else { return nil }

        if let prepared = prepareImageForBarcodeDetection(image) {
            if let s = detectWithVision(cgImage: prepared.cgImage, orientation: prepared.orientation) {
                return s.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if let s = detectWithCoreImage(ciImage: CIImage(cgImage: prepared.cgImage)) {
                return s.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        if let s = detectWithCoreImage(image: image) {
            return s.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return nil
    }
}

// MARK: - Private

private extension QRCodeImageScanner {
    /// Photos / Files often yield `UIImage` with `cgImage == nil` (CIImage-backed or deferred decode). Rendering fixes that.
    /// Very large images are downscaled so Vision stays reliable and within memory limits.
    static func prepareImageForBarcodeDetection(_ image: UIImage) -> (cgImage: CGImage, orientation: CGImagePropertyOrientation)? {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let maxDimension: CGFloat = 2048
        let longest = max(pixelWidth, pixelHeight)
        let needsDownscale = longest > maxDimension
        let downscale = needsDownscale ? maxDimension / longest : 1

        if image.cgImage != nil, !needsDownscale, let cg = image.cgImage {
            return (cg, cgImagePropertyOrientation(from: image.imageOrientation))
        }

        let target = CGSize(
            width: max(pixelWidth * downscale, 1),
            height: max(pixelHeight * downscale, 1)
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let rendered = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        guard let cg = rendered.cgImage else { return nil }
        return (cg, .up)
    }

    static func detectWithVision(cgImage: CGImage, orientation: CGImagePropertyOrientation) -> String? {
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        if #available(iOS 17.0, *) {
            request.revision = 3
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        do {
            try handler.perform([request])
            return request.results?.compactMap { stringFromBarcodeObservation($0) }.first
        } catch {
            return nil
        }
    }

    static func stringFromBarcodeObservation(_ observation: VNBarcodeObservation) -> String? {
        if let s = observation.payloadStringValue, !s.isEmpty {
            return s
        }
        if #available(iOS 17.0, *) {
            if let data = observation.payloadData, let s = String(data: data, encoding: .utf8), !s.isEmpty {
                return s
            }
        }
        return nil
    }

    static func detectWithCoreImage(image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        return detectWithCoreImage(ciImage: ciImage)
    }

    static func detectWithCoreImage(ciImage: CIImage) -> String? {
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let detector = CIDetector(
            ofType: CIDetectorTypeQRCode,
            context: context,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        guard let message = features?.first?.messageString, !message.isEmpty else { return nil }
        return message
    }

    static func cgImagePropertyOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

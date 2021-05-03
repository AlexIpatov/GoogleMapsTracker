//
//  UIImage + Extension.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 25.04.2021.
//

import UIKit

extension UIImage {
    func resizeForMapMark(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return scaledImage
    }
}

//
//  UIButton + Extension.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 03.04.2021.
//

import UIKit

extension UIButton {
    convenience init(image: UIImage?,
                     cornerRadius: CGFloat) {
        self.init(type: .system)
        self.setImage(image, for: .normal)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        self.layer.cornerRadius = cornerRadius
        self.translatesAutoresizingMaskIntoConstraints = false
        self.tintColor = .white

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}


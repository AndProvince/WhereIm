//
//  EmojiAnnotation.swift
//  WhereIm
//
//  Created by Андрей on 25.07.2024.
//

import Foundation
import SwiftUI
import MapKit

struct EmojiAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var emoji: String
}

class EmojiMKAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let image: UIImage?
    let id: String

    init(emojiAnnotation: EmojiAnnotation) {
        self.coordinate = emojiAnnotation.coordinate
        self.image = emojiAnnotation.emoji.image()
        self.id = emojiAnnotation.id.description
    }
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        (self as NSString).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 32)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

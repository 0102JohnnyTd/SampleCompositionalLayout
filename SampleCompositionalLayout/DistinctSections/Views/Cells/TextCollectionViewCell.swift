//
//  TextCollectionViewCell.swift
//  SampleCompositionalLayout
//
//  Created by Johnny Toda on 2023/01/03.
//

import UIKit

final class TextCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var flameImageView: UIImageView!

    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }

    func configure(number: Int) {
        numberLabel.text = String(number)
    }
}

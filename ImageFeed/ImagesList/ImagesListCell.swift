//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 22.05.2025.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    static let reuseIdentifier = "ImagesListCell"
}

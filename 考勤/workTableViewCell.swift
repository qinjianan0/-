//
//  workTableViewCell.swift
//  考勤
//
//  Created by Foxconn 38 on 2017/11/22.
//  Copyright © 2017年 Foxconn 38. All rights reserved.
//

import UIKit

class workTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var workTextField: UITextField!
    @IBOutlet weak var freeTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
    remarkTextField.textColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

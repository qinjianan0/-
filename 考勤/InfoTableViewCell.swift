//
//  InfoTableViewCell.swift
//  考勤
//
//  Created by Foxconn 38 on 2017/11/21.
//  Copyright © 2017年 Foxconn 38. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var outLabel: UILabel!
    @IBOutlet weak var worktimeLabel: UILabel!
    @IBOutlet weak var freetimeLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var outTextField: UITextField!
    @IBOutlet weak var workTextField: UITextField!
    @IBOutlet weak var freetimeTextField: UITextField!
    @IBOutlet weak var remarkTimeField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ProfileViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

internal final class ProfileViewController: UIViewController {

    internal static func instantiate() -> ProfileViewController {
        let vc = Storyboards.Profile.instantiate(ProfileViewController.self)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    
}

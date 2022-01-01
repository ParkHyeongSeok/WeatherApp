//
//  UIViewController+scene.swift
//  RxWeather
//
//  Created by 박형석 on 2022/01/01.
//  Copyright © 2022 Keun young Kim. All rights reserved.
//

import UIKit

extension UIViewController {
    var sceneViewController: UIViewController {
        return self.children.first ?? self
    }
}

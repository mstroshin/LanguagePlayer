//
//  Extensions.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 22.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

extension UIViewController {
    static func createFromMainStoryboard<T>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
}

extension UITableView {
    func diffUpdate<D: Differentiable>(source: [D], target: [D], setData: ([D]) -> Void) {
        let changeset = StagedChangeset(source: source, target: target)
        reload(using: changeset, with: .fade, setData: setData)
    }
}

extension UICollectionView {
    func diffUpdate<D: Differentiable>(source: [D], target: [D], setData: ([D]) -> Void) {
        let changeset = StagedChangeset(source: source, target: target)
        reload(using: changeset, setData: setData)
    }
}

precedencegroup AssignmentPrecedence {}
infix operator ?=
func ?= <T: Any> (left: inout T, right: T?) {
    if let right = right {
        left = right
    }
}

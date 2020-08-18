//
//  TranslationView.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 20.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import UIKit

protocol TranslationViewDelegate: class {
    func addToDictionaryPressed()
}

class TranslationView: UIView {
    @IBOutlet private var backgroundView: UIView! {
        didSet {
            self.backgroundView.layer.cornerRadius = 8
        }
    }
    @IBOutlet private var translationLabel: UILabel!
    @IBOutlet private var dictionaryButton: UIButton!
    weak var delegate: TranslationViewDelegate?
        
    func set(state: TranslationViewState) {
        self.translationLabel.text = state.translation
        self.dictionaryButton.setImage(
            state.isAddedInDictionary ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"),
            for: .normal
        )
    }
    
    @IBAction func didPressDictionaryButton(_ sender: UIButton) {
        self.delegate?.addToDictionaryPressed()
    }
}

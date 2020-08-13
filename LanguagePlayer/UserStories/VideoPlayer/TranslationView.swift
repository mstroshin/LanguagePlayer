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
    func translationView(_ translationView: TranslationView, addToDictionary source: String, target: String)
}

class TranslationView: UIView {
    @IBOutlet private var wordLabel: UILabel!
    @IBOutlet private var translationLabel: UILabel!
    @IBOutlet private var dictionaryButton: UIButton!
    weak var delegate: TranslationViewDelegate?
    
    func set(source: String) {
        self.wordLabel.text = source
    }
    
    func set(translation: String) {
        self.translationLabel.text = translation
    }
    
    @IBAction func didPressDictionaryButton(_ sender: UIButton) {
        guard let source = self.translationLabel.text, let target = self.translationLabel.text else {
            return
        }
        
        self.delegate?.translationView(self, addToDictionary: source, target: target)
    }
}

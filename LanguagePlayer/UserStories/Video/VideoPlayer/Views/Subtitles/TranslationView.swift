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
    @IBOutlet private var translationLabel: UILabel!
    @IBOutlet private var dictionaryButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    weak var delegate: TranslationViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
    }
        
    func set(text: String) {
        self.translationLabel.text = text
    }
    
    func set(isTranslating: Bool) {
        self.activityIndicator.isHidden = !isTranslating
        self.translationLabel.isHidden = isTranslating
        self.dictionaryButton.isHidden = isTranslating
    }
    
    func set(isAddedToDictionary: Bool) {
        self.dictionaryButton.setImage(
            isAddedToDictionary ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"),
            for: .normal
        )
    }
    
    @IBAction func didPressDictionaryButton(_ sender: UIButton) {
        self.delegate?.addToDictionaryPressed()
    }
}

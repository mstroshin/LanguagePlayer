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
        
    func set(state: TranslationViewState) {
        self.activityIndicator.isHidden = !state.translating
        self.translationLabel.isHidden = state.translating
        self.dictionaryButton.isHidden = state.translating
        
        self.translationLabel.text = state.translation
        
        let isAddedInDictionary = state.isAddedInDictionary ?? false
        self.dictionaryButton.setImage(
            isAddedInDictionary ? UIImage(systemName: "star.fill") : UIImage(systemName: "star"),
            for: .normal
        )
    }
    
    @IBAction func didPressDictionaryButton(_ sender: UIButton) {
        self.delegate?.addToDictionaryPressed()
    }
}

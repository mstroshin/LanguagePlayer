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
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var translationLabel: UILabel!
    @IBOutlet var dictionaryButton: UIButton!
    weak var delegate: TranslationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func createFromXib() -> TranslationView {
        Bundle.main.loadNibNamed(
            String(describing: TranslationView.self),
            owner: nil,
            options: nil
        )?.first as! TranslationView
    }
    
    @IBAction func didPressDictionaryButton(_ sender: UIButton) {
        guard let source = self.translationLabel.text, let target = self.translationLabel.text else {
            return
        }
        
        self.delegate?.translationView(self, addToDictionary: source, target: target)
    }
}

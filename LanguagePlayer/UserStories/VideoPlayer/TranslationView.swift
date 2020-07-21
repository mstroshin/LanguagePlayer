//
//  TranslationView.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 20.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import UIKit

class TranslationView: UIView {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var translationLabel: UILabel!
    @IBOutlet var dictionaryButton: UIButton!
    
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
        print("TranslationView")
    }
}

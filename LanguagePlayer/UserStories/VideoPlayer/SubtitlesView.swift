//
//  SubtitlesView.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 20.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation
import UIKit

protocol SubtitlesViewDelegate: class {
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String, in rect: CGRect, in range: NSRange)
}

class SubtitlesView: UIView {
    weak var delegate: SubtitlesViewDelegate?
    var textColor = UIColor.white
    
    private var didSetupConstraints = false
    private let textView: UITextView
    
    init() {
        self.textView = UITextView()
        super.init(frame: .zero)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        self.textView = UITextView()
        super.init(coder: coder)
        
        self.setupView()
    }
    
    override func updateConstraints() {
        self.setupConstraintsIfNeeded()
        super.updateConstraints()
    }
    
    private func setupConstraintsIfNeeded() {
        if self.didSetupConstraints { return }
        
        self.addConstraints([
            self.textView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.textView.topAnchor.constraint(equalTo: self.topAnchor),
            self.textView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        self.didSetupConstraints = true
    }
    
    private func setupView() {
        self.backgroundColor = UIColor(named: "SubtitlesBackground")
        self.layer.cornerRadius = 8
        
        self.textView.isEditable = false
        self.textView.isSelectable = false
        self.textView.isScrollEnabled = false
        self.textView.showsVerticalScrollIndicator = false
        self.textView.showsHorizontalScrollIndicator = false
        self.textView.backgroundColor = .clear
        self.textView.textColor = self.textColor
        self.textView.textAlignment = .center
        self.textView.font = .systemFont(ofSize: 32, weight: .bold)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        tapGesture.numberOfTapsRequired = 1
        self.textView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func textTapped(recognizer: UITapGestureRecognizer) {
        guard let textView = recognizer.view as? UITextView else { return }
        let layoutManager = textView.layoutManager
        
        let location = recognizer.location(in: textView)
        let charIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard charIndex != 0 else { return }
                        
        if let textPosition = textView.closestPosition(to: location),
            let textRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: .storage(.forward)),
            let text = textView.text(in: textRange) {
            let range = self.toRange(textRange: textRange, for: textView)
            
            let wordRect = textView.firstRect(for: textRange)
            self.delegate?.subtitleView(self, didSelect: text, in: wordRect, in: range)
        }
    }
    
    
    
}

//Public methods
extension SubtitlesView {
    
    func set(text: String) {
        self.textView.text = text
    }
    
    func select(text: String) {
        guard let range = self.textView.text.range(of: text) else { return }
        let nsRange = NSRange(range, in: self.textView.text)
        
        let mutableText = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: nsRange)
        self.textView.attributedText = mutableText
    }
    
    func deselectAll() {
        let mutableText = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableText.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: self.textColor,
            range: NSRange(location: 0, length: self.textView.text.count)
        )
        self.textView.attributedText = mutableText
    }
    
}

//Support methods
extension SubtitlesView {
    
    private func toRange(textRange: UITextRange, for textView: UITextView) -> NSRange {
        let beginning = textView.beginningOfDocument
        let start = textRange.start
        let end = textRange.end
        let location = textView.offset(from: beginning, to: start)
        let length = textView.offset(from: start, to: end)
        
        return NSRange(location: location, length: length)
    }
    
}

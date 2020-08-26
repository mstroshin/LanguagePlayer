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
    func subtitleView(_ subtitlesView: SubtitlesView, didSelect text: String)
    func addToDictionaryPressed()
    func startedSelectingText(in subtitlesView: SubtitlesView)
}

class SubtitlesView: UIView {
    @IBOutlet private weak var translationView: TranslationView! {
        didSet {
            self.translationView.delegate = self
            self.translationView.isHidden = true
            self.bringSubviewToFront(self.translationView)
        }
    }
    weak var delegate: SubtitlesViewDelegate?
    var textColor = UIColor.white
    
    var currentText: String {
        self.textView.text
    }
    
    private var didSetupConstraints = false
    private var selectedTextRange: UITextRange?
    private var previousTextPosition: UITextPosition?
    private let textView: UITextView
    
    private var textShadow: NSShadow {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        shadow.shadowColor = UIColor.black
        
        return shadow
    }
    
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
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraints([
            self.textView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.textView.topAnchor.constraint(equalTo: self.topAnchor),
            self.textView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        self.didSetupConstraints = true
    }
    
    private func setupView() {
        self.backgroundColor = .clear
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
        self.textView.layer.shadowColor = UIColor.black.cgColor
        self.textView.layer.shadowRadius = 1.0
        self.textView.layer.shadowOpacity = 1.0
        self.textView.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.textView.layer.masksToBounds = false
        self.addSubview(self.textView)
                
        let tapGesture = SelectionGestureRecognizer(target: self, action: #selector(textTapped))
        self.textView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func textTapped(recognizer: UITapGestureRecognizer) {
        let textView = self.textView
        let location = recognizer.location(in: textView)
        guard let textPosition = textView.closestPosition(to: location) else { return }
        
        if recognizer.state == .began
        {
            self.deselectAll()
            
            if let textRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: .storage(.forward))
            {
                self.selectedTextRange = textRange
                self.select(textRange: textRange)
                self.delegate?.startedSelectingText(in: self)
            }
            self.previousTextPosition = textPosition
        }
        else if let selectedTextRange = self.selectedTextRange,
            let previousTextPosition = self.previousTextPosition,
            recognizer.state == .changed
        {
            var textRange: UITextRange?
            if textView.compare(previousTextPosition, to: textPosition) == .orderedAscending {
                //Forward
                if let endTextRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: .storage(.forward)) {
                    textRange = textView.textRange(from: selectedTextRange.start, to: endTextRange.end)
                }
            } else if textView.compare(previousTextPosition, to: textPosition) == .orderedDescending {
                //Backward
                if let endTextRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: .storage(.backward)) {
                    textRange = textView.textRange(from: endTextRange.start, to: selectedTextRange.end)
                }
            }
            
            if let textRange = textRange {
                self.selectedTextRange = textRange
                self.deselectAll()
                self.select(textRange: textRange)
            }
            
            self.previousTextPosition = textPosition
        }
        else if let textRange = self.selectedTextRange,
            let text = textView.text(in: textRange),
            recognizer.state == .ended
        {
            self.delegate?.subtitleView(self, didSelect: text)
            self.previousTextPosition = nil
//            self.selectedTextRange = nil
        }
    }
        
    private func select(textRange: UITextRange) {
        let nsRange = toNSRange(textRange: textRange, textView: self.textView)
        
        let mutableText = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: nsRange)
        self.textView.attributedText = mutableText
    }
    
    private func toNSRange(textRange: UITextRange, textView: UITextView) -> NSRange {
        let location = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let length = textView.offset(from: textRange.start, to: textRange.end)
        
        return NSRange(location: location, length: length)
    }
}

extension SubtitlesView: TranslationViewDelegate {
    func addToDictionaryPressed() {
        self.delegate?.addToDictionaryPressed()
    }
}

//Public methods
extension SubtitlesView {
    
    func set(text: String) {
        self.textView.text = text
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
    
    func showTranslated(_ state: TranslationViewState) {
        self.translationView.set(state: state)
        self.translationView.isHidden = false
    }
    
    func hideTranslationView() {
        self.translationView.isHidden = true
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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.clipsToBounds || self.isHidden || self.alpha == 0 {
            return nil
        }
        
        if !self.bounds.contains(point) {
            return self.translationView.hitTest(self.convert(point, to: self.translationView), with: event)
        }
        
        return super.hitTest(point, with: event)
    }
    
}

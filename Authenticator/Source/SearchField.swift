//
//  SearchField.swift
//  Authenticator
//
//  Copyright (c) 2013-2019 Authenticator authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

// A custom view that contains a SearchTextField displaying its placeholder centered in the
// text field.
//
// Displays a ProgressRingView as the `leftView` control.
class SearchField: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }

    weak var delegate: UITextFieldDelegate? {
        get { return textField.delegate }
        set { textField.delegate = newValue }
    }

    var text: String? {
        return textField.text
    }

    let ring = ProgressRingView(
        frame: CGRect(origin: .zero, size: CGSize(width: 22, height: 22))
    )

    let textField: UITextField = SearchTextField()

    private func setupTextField() {
        ring.tintColor = UIColor(named: "foregroundColor")
        textField.attributedPlaceholder = NSAttributedString(
            string: "Authenticator",
            attributes: [
                .foregroundColor: UIColor(named: "foregroundColor")!,
                .font: UIFont.systemFont(ofSize: 16, weight: .light),
            ]
        )
        textField.textColor = UIColor(named: "foregroundColor")
        textField.backgroundColor = UIColor(named: "backgroundColor")!.withAlphaComponent(0.2)
        textField.leftView = ring
        textField.leftViewMode = .always
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .always
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.sizeToFit()
        addSubview(textField)
    }

    override var intrinsicContentSize: CGSize {
        return ring.frame.union(textField.frame).size
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fieldSize = textField.frame.size
        let fits = CGSize(width: max(size.width, fieldSize.width), height: fieldSize.height)
        return fits
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // center the text field
        var textFieldFrame = textField.frame
        textFieldFrame.size.width = bounds.size.width
        textField.frame = textFieldFrame
        textField.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    }
}

// MARK: TokenListPresenter
extension SearchField {
    func update(with viewModel: TokenList.ViewModel) {
        if let progressRingViewModel = viewModel.progressRingViewModel {
            ring.update(with: progressRingViewModel)
        }
        // Show the countdown ring only if a time-based token is active
        textField.leftViewMode = viewModel.progressRingViewModel != nil ? .always : .never

        // Only display text field as editable if there are tokens to filter
        textField.isEnabled = viewModel.hasTokens
        textField.borderStyle = viewModel.hasTokens ? .roundedRect : .none
        textField.backgroundColor = viewModel.hasTokens ?
            UIColor(named: "backgroundColor")!.withAlphaComponent(0.1) : UIColor.clear
    }
}

// MARK: UITextField rect overrides
class SearchTextField: UITextField {
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: bounds).offsetBy(dx: 6, dy: 0)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if self.isFirstResponder {
            return .zero
        }
        var rect = super.placeholderRect(forBounds: bounds)
        if let size = attributedPlaceholder?.size() {
            rect.size.width = size.width
            rect.origin.x = (bounds.size.width - rect.size.width) * 0.5
        }
        return rect
    }
}

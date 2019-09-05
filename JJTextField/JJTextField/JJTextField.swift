//
//  JJTextField.swift
//  JJTextField
//
//  Created by yubing.li on 2019/9/4.
//  Copyright © 2019 Matrixport. All rights reserved.
//

import UIKit

class JJTextField: UITextField {
    
    enum AcceptedCharacterSet {
        case `defalut`
        case number
        case decimal
        case designate(cs: String)
    }
    
    /// 最长可输入字符个数
    var maxLength: Int = 255 {
        didSet {
            _delegate.maxLength = maxLength
        }
    }
    
    /// 接受收入的字符集
    var acceptedCharacterSet: JJTextField.AcceptedCharacterSet = .defalut {
        didSet {
            _delegate.acceptedCharacterSet = acceptedCharacterSet
        }
    }
    
    ///小数点后最多几位数字，仅在decimal模式下生效
    var lengthAfterPoint: Int = 8 {
        didSet {
            _delegate.lengthAfterPoint = lengthAfterPoint
        }
    }
    
    ///decimal模式下的限制，仅在decimal模式下生效: 1.首字母不能为小数点 2.不能同时输入两个小数点
    var enableDecimalLimitMode: Bool = true {
        didSet {
            _delegate.enableDecimalLimitMode = enableDecimalLimitMode
        }
    }
    
    /// 代理
    override var delegate: UITextFieldDelegate? {
        set {
            super.delegate = _delegate
            if !_delegate.isEqual(newValue) {
                _delegate.delegate = newValue
            }
        }
        get {
            return _delegate.delegate
        }
    }
    
    /// 开始编辑
    var onBeginEdit: ((JJTextField) -> Void)?
    
    /// 编辑回调
    var onEditing: ((String?) -> Void)?
    
    /// 结束编辑
    var onEndEdit: ((JJTextField) -> Void)?
    
    private let _delegate = JJTextFieldFormatter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autocorrectionType = .no
        delegate = _delegate
        addNoti()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(onBeginEditEvent(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onEndEditEvent(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    @objc private func onBeginEditEvent(_ sender: Notification) -> Void {
        let object = sender.object as? JJTextField
        if object == self {
            onBeginEdit?(self)
        }
    }
    
    @objc private func onTextChanged(_ sender: Notification) -> Void {
        let object = sender.object as? JJTextField
        if object == self {
            onEditing?(text)
        }
    }
    
    @objc private func onEndEditEvent(_ sender: Notification) -> Void {
        let object = sender.object as? JJTextField
        if object == self {
            onEndEdit?(self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

private class JJTextFieldFormatter: NSObject, UITextFieldDelegate {
    
    weak var delegate: UITextFieldDelegate?
    var maxLength: Int = 255
    var acceptedCharacterSet: JJTextField.AcceptedCharacterSet = .defalut
    var lengthAfterPoint: Int = 8
    var enableDecimalLimitMode: Bool = true
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let ocString = textField.text as NSString?
        let transformed = (ocString?.replacingCharacters(in: range, with: string)) as String?
        let targetString: String = transformed ?? ""
        guard lengthCheck(string: targetString) else { return false }
        guard characterSetCheck(string: targetString) else { return false }
        guard addtionDecimalCheck(newText: targetString) else { return false }
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    private func lengthCheck(string: String) -> Bool {
        return string.count <= maxLength
    }
    
    private func characterSetCheck(string: String) -> Bool {
        switch acceptedCharacterSet {
        case .defalut: return true
        case .number:
            let set = "1234567890"
            return handle(TextChanged: string, verifyWithAcceptedCharacterSet: set)
        case .decimal:
            let set = "1234567890."
            return handle(TextChanged: string, verifyWithAcceptedCharacterSet: set)
        case .designate(cs: let set):
            return handle(TextChanged: string, verifyWithAcceptedCharacterSet: set)
        }
    }
    
    private func handle(TextChanged newText: String, verifyWithAcceptedCharacterSet set: String) -> Bool {
        guard newText.count > 0 else { return true }
        let lastChar = "\(newText.last!)"
        let filted = filt(Text: lastChar, withCharacterSet: set)
        return filted != lastChar
    }
    
    private func filt(Text newText: String, withCharacterSet set: String) -> String {
        let cs = CharacterSet(charactersIn: set)
        return newText.components(separatedBy: cs).joined(separator: "")
    }
    
    private func addtionDecimalCheck(newText: String) -> Bool {
        switch acceptedCharacterSet {
        case .decimal:
            guard newText.count > 0 else { return true }
            if self.enableDecimalLimitMode {
                if newText.first! == "." {
                    return false
                }
            }
            let slice = newText.components(separatedBy: ".")
            if slice.count == 2 {
                let left = slice[0]
                let right = slice[1]
                if left.count > 0 && right.count > 0 {
                    if right.count > self.lengthAfterPoint {
                        return false
                    }
                }
            } else if slice.count > 2 {
                return false
            }
            return true
        default:
            return true
        }
    }
    
}

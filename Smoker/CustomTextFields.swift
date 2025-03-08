//
//  CustomTextFields.swift
//  Smoker
//
//  Created by Artem Hitin on 08.03.2025.
//


import SwiftUI

struct NumberTextField: UIViewRepresentable {
    private var placeholder: String
    private var keyboardType: UIKeyboardType
    @Binding private var text: String
    var onCommit: (String) -> Void

    init(_ placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType, onCommit: @escaping (String) -> Void = {_ in}) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.onCommit = onCommit
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = keyboardType
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        context.coordinator.textField = textField

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )

        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onCommit: onCommit)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var onCommit: (String) -> Void
        weak var textField: UITextField?

        init(text: Binding<String>, onCommit: @escaping (String) -> Void) {
            self._text = text
            self.onCommit = onCommit
        }

        @objc func dismissKeyboard() {
            guard let textField = textField else { return }

            let newValue = textField.text ?? ""
            text = newValue

            textField.resignFirstResponder()
            onCommit(newValue)
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

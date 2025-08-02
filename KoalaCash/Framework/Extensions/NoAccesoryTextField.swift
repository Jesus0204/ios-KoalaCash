//
//  NoAccesoryTextField.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import SwiftUI

struct NoAccessoryTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.delegate = context.coordinator
        tf.inputAssistantItem.leadingBarButtonGroups.removeAll()
        tf.inputAssistantItem.trailingBarButtonGroups.removeAll()
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

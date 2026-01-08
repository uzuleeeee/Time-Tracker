//
//  CategoryConfigurationView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/8/26.
//

import SwiftUI

struct CategoryConfigurationView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var emoji: String = ""
    @State private var name: String = ""
    
    var onSave: (String, String) -> Void
    
    private var isValid: Bool {
        emoji.isEmpty == false && name.isEmpty == false
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Icon", text: $emoji)
                        .lineLimit(1)
                        .textFieldStyle(.plain)
                        .frame(maxWidth: 50)
                    
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .opacity(0.1)
                    
                    TextField("Name", text: $name)
                        .lineLimit(1)
                        .textFieldStyle(.plain)
                }
            }
            
            Button {
                onSave(emoji, name)
                
                dismiss()
            } label: {
                Image(systemName: "plus")
                    .padding()
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(isValid ? Color(.systemBackground) : Color(.systemBackground).opacity(0.7))
                    .background(isValid ? Color(uiColor: .label) : .gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.borderless)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .disabled(!isValid)
        }
    }
}

#Preview {
    CategoryConfigurationView { emoji, name in
        print(emoji, name)
    }
}

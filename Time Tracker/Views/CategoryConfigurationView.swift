//
//  CategoryConfigurationView.swift
//  Time Tracker
//
//  Created by Mac-aroni on 1/8/26.
//

import SwiftUI

struct CategoryConfigurationView: View {
    @Environment(\.dismiss) var dismiss
    
    enum FocusField {
        case emoji
        case name
    }
    
    @FocusState private var focusedField: FocusField?
    
    @State private var emoji: String = ""
    @State private var name: String = ""
    
    var onSave: (String, String) -> Void
    
    private var isValid: Bool {
        emoji.isBlank == false && name.isBlank == false
    }
    
    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    ZStack {
                        Color(.secondarySystemGroupedBackground)
                        
                        TextField("😀", text: $emoji)
                            .font(.system(size: 30))
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .focused($focusedField, equals: .emoji)
                            .onChange(of: emoji) { newValue in
                                if newValue.count >= 1 {
                                    emoji = String(newValue.prefix(1))
                                    
                                    focusedField = .name
                                }
                            }
                            .tint(.primary)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    TextField("Name", text: $name)
                        .padding(.horizontal)
                        .frame(height: 50)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .tint(.primary)
                        .focused($focusedField, equals: .name)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
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
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.borderless)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .disabled(!isValid)
        }
        .onAppear {
            focusedField = .emoji
        }
    }
}

#Preview {
    CategoryConfigurationView { emoji, name in
        print(emoji, name)
    }
}

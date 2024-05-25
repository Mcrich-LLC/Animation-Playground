//
//  AnimationView.swift
//  Animation Playground
//
//  Created by Morris Richman on 5/25/24.
//

import SwiftUI

struct AnimationView: View {
    @Bindable var dbAnimation: DBAnimation
    let animation: Animation
    @State var isShowing = false
    @State var isEditingPresentedText = false
    @FocusState var isEditingPresentedTextKeyboard
    @FocusState var isAdjustingSpeed
    
    var speedBinding: Binding<String> {
        Binding {
            if let speed = dbAnimation.speed {
                return "\(speed)"
            } else {
                return ""
            }
        } set: { newValue in
            guard !newValue.isEmpty, let double = Double(newValue) else {
                dbAnimation.speed = nil
                return
            }
            
            dbAnimation.speed = double
        }

    }
    
    var runAnimation: Animation {
        guard let speed = dbAnimation.speed else {
            return animation
        }
        
        return animation.speed(speed)
    }
    
    var body: some View {
        List {
            Section {
                if isShowing {
                    HStack {
                        if isEditingPresentedText {
                            TextField("", text: $dbAnimation.presentedText, prompt: Text("Presented Text"))
                                .focused($isEditingPresentedTextKeyboard)
                        } else {
                            Text(dbAnimation.presentedText)
                        }
                        Button {
                            if isEditingPresentedText {
                                isEditingPresentedTextKeyboard = false
                                if dbAnimation.presentedText.isEmpty {
                                    dbAnimation.presentedText = "Your Content via \(dbAnimation.title)"
                                }
                                withAnimation(runAnimation) {
                                    isEditingPresentedText = false
                                }
                            } else {
                                withAnimation(runAnimation) {
                                    isEditingPresentedText = true
                                    isEditingPresentedTextKeyboard = true
                                }
                            }
                        } label: {
                            Image(systemName: isEditingPresentedText ? "checkmark" : "pencil")
                        }
                        
                    }
                }
                
                if !isEditingPresentedText {
                    Button("Try Animation") {
                        isAdjustingSpeed = false
                        isEditingPresentedTextKeyboard = false
                        withAnimation(runAnimation) {
                            isShowing.toggle()
                        }
                    }
                    .buttonBorderShape(.roundedRectangle)
                    
                    HStack {
                        Text("Animation Speed: ")
                        TextField("", text: speedBinding, prompt: Text("Default"))
#if os(iOS)
                            .keyboardType(.decimalPad)
#endif
                            .focused($isAdjustingSpeed)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            
            if !isEditingPresentedText {
                Section("Code") {
                    Text(code)
                        .overlay(alignment: .topTrailing) {
                            Button {
#if os(iOS)
                                UIPasteboard.general.string = code
#endif
#if os(macOS)
                                let pasteboard = NSPasteboard.general
                                pasteboard.declareTypes([.string], owner: nil)
                                pasteboard.setString(code, forType: .string)
#endif
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            
                        }
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isEditingPresentedTextKeyboard = false
                        isAdjustingSpeed = false
                        withAnimation(runAnimation) {
                            isEditingPresentedText = false
                        }
                    }
                }
            }
        })
        .navigationTitle(dbAnimation.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .onChange(of: dbAnimation) {
            isShowing = false
        }
//        .padding()
    }
    
    
    
    var code: String {
        """
import SwiftUI

struct ContentView: View {
    let animation: Animation = .\(dbAnimation.animation)
    @State var isShowing = false
    @State var presentedText = "Your Content via \(dbAnimation.title)"
    @State var isEditingPresentedText = false
    @FocusState var isEditingPresentedTextKeyboard
    @FocusState var isAdjustingSpeed
    @State var speed: Double?
    
    var speedBinding: Binding<String> {
        Binding {
            if let speed = speed {
                return "\\(speed)"
            } else {
                return ""
            }
        } set: { newValue in
            guard !newValue.isEmpty, let double = Double(newValue) else {
                speed = nil
                return
            }
            
            speed = double
        }

    }
    
    var runAnimation: Animation {
        guard let speed = speed else {
            return animation
        }
        
        return animation.speed(speed)
    }
    
    var body: some View {
        List {
            Section {
                if isShowing {
                    HStack {
                        if isEditingPresentedText {
                            TextField("", text: $presentedText, prompt: Text("Presented Text"))
                                .focused($isEditingPresentedTextKeyboard)
                        } else {
                            Text(presentedText)
                        }
                        Button {
                            if isEditingPresentedText {
                                isEditingPresentedTextKeyboard = false
                                if presentedText.isEmpty {
                                    presentedText = "Your Content via \(dbAnimation.title)"
                                }
                                withAnimation(runAnimation) {
                                    isEditingPresentedText = false
                                }
                            } else {
                                withAnimation(runAnimation) {
                                    isEditingPresentedText = true
                                    isEditingPresentedTextKeyboard = true
                                }
                            }
                        } label: {
                            Image(systemName: isEditingPresentedText ? "checkmark" : "pencil")
                        }
                        
                    }
                }
                
                if !isEditingPresentedText {
                    Button("Try Animation") {
                        isAdjustingSpeed = false
                        isEditingPresentedTextKeyboard = false
                        withAnimation(runAnimation) {
                            isShowing.toggle()
                        }
                    }
                    .buttonBorderShape(.roundedRectangle)
                    
                    HStack {
                        Text("Animation Speed: ")
                        TextField("", text: speedBinding, prompt: Text("Default"))
#if os(iOS)
                            .keyboardType(.decimalPad)
#endif
                            .focused($isAdjustingSpeed)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isEditingPresentedTextKeyboard = false
                        isAdjustingSpeed = false
                        withAnimation(runAnimation) {
                            isEditingPresentedText = false
                        }
                    }
                }
            }
        })
        .navigationTitle("\(dbAnimation.title)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}
"""
    }
}

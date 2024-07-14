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
    @State var isJustEditingPresentedText = false
    @FocusState var isEditingPresentedTextKeyboard
    @FocusState var isAdjustingSpeed
    @Environment(\.colorScheme) var colorScheme
    
    // Section Backround
    var animationViewCellBackground: Color {
        #if canImport(UIKit)
        switch colorScheme {
        case .light:
            return Color(uiColor: .systemBackground)
        case .dark:
            return Color(uiColor: .secondarySystemBackground)
        @unknown default:
            return Color(uiColor: .systemBackground)
        }
        #elseif canImport(AppKit)
        return Color(nsColor: .systemFill)
        #endif
    }
    
    // View Background
    var animationViewBackground: Color {
        #if canImport(UIKit)
        switch colorScheme {
        case .light:
            return Color(uiColor: .secondarySystemBackground)
        case .dark:
            return Color(uiColor: .systemBackground)
        @unknown default:
            return Color(uiColor: .secondarySystemBackground)
        }
        #elseif canImport(AppKit)
        return Color.clear
        #endif
    }
    
    var speedBinding: Binding<String> {
        Binding {
            if let speed = dbAnimation.speed {
                return "\(speed)"
            } else {
                return ""
            }
        } set: { newValue in
            guard !newValue.isEmpty, let double = Double(newValue), double != 0 else {
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
    
    func toggleIsEditingPresentedText() {
        if isEditingPresentedText || isJustEditingPresentedText {
            isEditingPresentedTextKeyboard = false
            if dbAnimation.presentedText.isEmpty {
                dbAnimation.presentedText = "Your Content via \(dbAnimation.title)"
            }
            withAnimation(runAnimation) {
                isEditingPresentedText = false
                isJustEditingPresentedText = false
            }
        } else {
            withAnimation(runAnimation) {
                #if os(macOS)
                isJustEditingPresentedText = true
                #else
                isEditingPresentedText = true
                #endif
                isEditingPresentedTextKeyboard = true
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    if isShowing {
                        HStack {
                            if isEditingPresentedText || isJustEditingPresentedText {
                                TextField("", text: $dbAnimation.presentedText, prompt: Text("Presented Text"))
                                    .focused($isEditingPresentedTextKeyboard)
                                    .onSubmit {
                                        toggleIsEditingPresentedText()
                                    }
                            } else {
                                Text(dbAnimation.presentedText)
                            }
                            Button {
                                toggleIsEditingPresentedText()
                            } label: {
                                Image(systemName: (isEditingPresentedText || isJustEditingPresentedText) ? "checkmark" : "pencil")
                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if !isEditingPresentedText {
                        if isShowing {
                            Divider()
                        }
                        HStack {
                            Button {
                                isAdjustingSpeed = false
                                isEditingPresentedTextKeyboard = false
                                withAnimation(runAnimation) {
                                    isShowing.toggle()
                                }
                            } label: {
                                Text("Try Animation")
                            }
                            .buttonBorderShape(.roundedRectangle)
                            Spacer()
                        }
                        Divider()
                        
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
                .padding()
                .background(animationViewCellBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12.5))
                #if canImport(UIKit)
                .padding(UIDevice.current.userInterfaceIdiom == .phone ? [] : [.top])
                #elseif canImport(AppKit)
                .padding(.top)
                #endif
                
                if !isEditingPresentedText {
                    DisclosureGroup {
                        VStack {
                            Text(code)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                        .padding()
                        .background(animationViewCellBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12.5))
                    } label: {
                        Text("Code")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .bold()
                    }
                    .padding(.top, 15)
                    .padding(.bottom)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .toolbar(content: {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isEditingPresentedTextKeyboard = false
                        isAdjustingSpeed = false
                        withAnimation(runAnimation) {
                            isEditingPresentedText = false
                            isJustEditingPresentedText = false
                        }
                    }
                }
            }
        })
        .navigationTitle(dbAnimation.title)
        .onChange(of: dbAnimation) {
            isShowing = false
        }
        
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .padding(.horizontal)
        
        #if canImport(UIKit)
        .frame(maxHeight: UIDevice.current.userInterfaceIdiom == .phone ? .infinity : nil)
        #endif
        .background(animationViewBackground)
    }
    
    
    
    var code: String {
        """
import SwiftUI

struct ContentView: View {
    let animation: Animation = .\(dbAnimation.animation)
    @State var isShowing = false
    @State var presentedText = "\(dbAnimation.presentedText)"
    @State var isEditingPresentedText = false
    @State var isJustEditingPresentedText = false
    @FocusState var isEditingPresentedTextKeyboard
    @FocusState var isAdjustingSpeed
    @State var speed: Double?
    @Environment(\\.colorScheme) var colorScheme
        
    // Section Backround
    var animationViewCellBackground: Color {
        #if canImport(UIKit)
        switch colorScheme {
        case .light:
            return Color(uiColor: .systemBackground)
        case .dark:
            return Color(uiColor: .secondarySystemBackground)
        @unknown default:
            return Color(uiColor: .systemBackground)
        }
        #elseif canImport(AppKit)
        return Color(nsColor: .systemFill)
        #endif
    }
    
    // View Background
    var animationViewBackground: Color {
        #if canImport(UIKit)
        switch colorScheme {
        case .light:
            return Color(uiColor: .secondarySystemBackground)
        case .dark:
            return Color(uiColor: .systemBackground)
        @unknown default:
            return Color(uiColor: .secondarySystemBackground)
        }
        #elseif canImport(AppKit)
        return Color.clear
        #endif
    }
    
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

    func toggleIsEditingPresentedText() {
        if isEditingPresentedText || isJustEditingPresentedText {
            isEditingPresentedTextKeyboard = false
            if presentedText.isEmpty {
                presentedText = "Your Content via \(dbAnimation.title)"
            }
            withAnimation(runAnimation) {
                isEditingPresentedText = false
                isJustEditingPresentedText = false
            }
        } else {
            withAnimation(runAnimation) {
                #if os(macOS)
                isJustEditingPresentedText = true
                #else
                isEditingPresentedText = true
                #endif
                isEditingPresentedTextKeyboard = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack {
                        if isShowing {
                            HStack {
                                if isEditingPresentedText || isJustEditingPresentedText {
                                    TextField("", text: $presentedText, prompt: Text("Presented Text"))
                                        .focused($isEditingPresentedTextKeyboard)
                                        .onSubmit {
                                            toggleIsEditingPresentedText()
                                        }
                                } else {
                                    Text(presentedText)
                                }
                                Button {
                                    toggleIsEditingPresentedText()
                                } label: {
                                    Image(systemName: (isEditingPresentedText || isJustEditingPresentedText) ? "checkmark" : "pencil")
                                }
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if !isEditingPresentedText {
                            if isShowing {
                                Divider()
                            }
                            HStack {
                                Button {
                                    isAdjustingSpeed = false
                                    isEditingPresentedTextKeyboard = false
                                    withAnimation(runAnimation) {
                                        isShowing.toggle()
                                    }
                                } label: {
                                    Text("Try Animation")
                                }
                                .buttonBorderShape(.roundedRectangle)
                                Spacer()
                            }
                            Divider()
                            
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
                    .padding()
                    .background(animationViewCellBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12.5))
                    #if canImport(UIKit)
                    .padding(UIDevice.current.userInterfaceIdiom == .phone ? [] : [.top])
                    #elseif canImport(AppKit)
                    .padding(.top)
                    #endif
                }
            }
            .scrollContentBackground(.hidden)
            .toolbar(content: {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isEditingPresentedTextKeyboard = false
                            isAdjustingSpeed = false
                            withAnimation(runAnimation) {
                                isEditingPresentedText = false
                                isJustEditingPresentedText = false
                            }
                        }
                    }
                }
            })
            .navigationTitle("\(dbAnimation.title)")
            
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .padding(.horizontal)
            
            #if canImport(UIKit)
            .frame(maxHeight: UIDevice.current.userInterfaceIdiom == .phone ? .infinity : nil)
            #endif
            .background(animationViewBackground)
        }
    }
}
"""
    }
}

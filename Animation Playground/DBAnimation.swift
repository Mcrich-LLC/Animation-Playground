//
//  DBAnimation.swift
//  Animation Playground
//
//  Created by Morris Richman on 5/25/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class DBAnimation: Identifiable {
    @Attribute(.unique)
    var id: UUID
    var title: String
    var animation: SavedAnimation.RawValue
    var speed: Double?
    var presentedText: String
    
    init(title: String, animation: Animation, speed: Double? = nil, presentedText: String) {
        self.id = UUID()
        self.title = title
        self.animation = SavedAnimation.animationToSavedAnimation(animation).rawValue
        self.speed = speed
        self.presentedText = presentedText
    }
    
    init(title: String, animation: Animation, speed: Double? = nil) {
        self.id = UUID()
        self.title = title
        self.animation = SavedAnimation.animationToSavedAnimation(animation).rawValue
        self.speed = speed
        self.presentedText = "Your Content via \(title)"
    }
    
    static let animations: [DBAnimation] = SavedAnimation.allCases.map { savedAnimation in
        DBAnimation(title: "\(String(savedAnimation.rawValue.first ?? Character("")).capitalized)\(savedAnimation.rawValue.dropFirst())", animation: savedAnimation.toAnimation())
    }.sorted(by: { $0.title < $1.title })
}


enum SavedAnimation: String, CaseIterable {
    case `default`
    case bouncy
    case easeIn
    case easeInOut
    case easeOut
    case interactiveSpring
    case interpolatingSpring
    case linear
    case snappy
    case smooth
    case spring
    
    static func animationToSavedAnimation(_ animation: Animation) -> SavedAnimation {
        switch animation {
        case .default: return .default
        case .bouncy: return .bouncy
        case .easeIn: return .easeIn
        case .easeInOut: return .easeInOut
        case .easeOut: return .easeOut
        case .interactiveSpring: return .interactiveSpring
        case .interpolatingSpring: return .interpolatingSpring
        case .linear: return .linear
        case .snappy: return .snappy
        case .smooth: return .smooth
        case .spring: return .spring
        default:
            return .default
        }
    }
    
    func toAnimation() -> Animation {
        return Self.savedAnimationToAnimation(self)
    }
    
    static func savedAnimationToAnimation(_ animation: SavedAnimation) -> Animation {
        switch animation {
        case .default: return .default
        case .bouncy: return .bouncy
        case .easeIn: return .easeIn
        case .easeInOut: return .easeInOut
        case .easeOut: return .easeOut
        case .interactiveSpring: return .interactiveSpring
        case .interpolatingSpring: return .interpolatingSpring
        case .linear: return .linear
        case .snappy: return .snappy
        case .smooth: return .smooth
        case .spring: return .spring
        }
    }
    
    init(animation: Animation) {
        self = Self.animationToSavedAnimation(animation)
    }
}

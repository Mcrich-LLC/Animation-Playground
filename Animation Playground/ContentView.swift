//
//  ContentView.swift
//  Animation Playground
//
//  Created by Morris Richman on 5/25/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var animations: [DBAnimation]
    

    var body: some View {
        NavigationSplitView {
            List {
                Section("Animations") {
                    ForEach(animations) { animation in
                        if let swiftAnimation = SavedAnimation(rawValue: animation.animation)?.toAnimation() {
                            NavigationLink {
                                AnimationView(dbAnimation: animation, animation: swiftAnimation)
                            } label: {
                                Text(animation.title)
                            }
                        }
                    }
                    .onDelete(perform: deleteAnimations)
                }
            }
            .navigationTitle("Animation Playground")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addAnimation) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
        } detail: {
            Text("Select an item")
        }
        .onAppear(perform: {
            if animations.isEmpty {
                for animation in DBAnimation.animations {
                    modelContext.insert(animation)
                }
            }
        })
    }

    
    private func addAnimation() {
        withAnimation {
            let newItem = DBAnimation(title: "Test", animation: .default)
            modelContext.insert(newItem)
        }
    }

    private func deleteAnimations(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(animations[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DBAnimation.self, inMemory: true)
}

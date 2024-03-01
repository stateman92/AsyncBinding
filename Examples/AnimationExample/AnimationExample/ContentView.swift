//
//  ContentView.swift
//  AnimationExample
//
//  Created by Kristóf Kálai on 01/03/2024.
//

import AsyncExtensions
import AsyncBinding
import SwiftUI

final class ViewModel: ObservableObject {
    private let colorSubject = AsyncCurrentValueSubject(Color.red)
    var colorSequence: AnyAsyncSequence<Color> {
        colorSubject.eraseToAnyAsyncSequence()
    }

    init() {
        // Doesn't work:
        // withAnimation(.linear(duration: 5).delay(1)) {
        //     colorSubject.send(.blue)
        // }

        // Doesn't work with the previous solution, but now works:
        colorSubject.send(.blue)
    }
}

struct StateView: View {
    @State private var color: Color = .red

    var body: some View {
        RectangleView(color: color)
            .onAppear {
                withAnimation(.linear(duration: 5).delay(1)) {
                    color = .blue
                }
            }
    }
}

struct AsyncBindingView: View {
    // Previous solution: doesn't work
    // @AsyncBinding private var color: Color = .red

    // New solution, works
    @AsyncBinding(animation: .linear(duration: 5).delay(1)) private var color: Color = .red

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        RectangleView(color: color)
            .bind {
                viewModel.colorSequence.assign(to: $color)
            }
    }
}

struct RectangleView: View {
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 100, height: 100)
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            StateView()
            Divider()
            AsyncBindingView()
        }
    }
}

#Preview {
    ContentView()
}

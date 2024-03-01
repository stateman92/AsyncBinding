//
//  ContentView.swift
//  ListAnimationExample
//
//  Created by Kristóf Kálai on 01/03/2024.
//

import AsyncExtensions
import AsyncBinding
import SwiftUI

final class ViewModel: ObservableObject {
    private let colorsSubject = AsyncCurrentValueSubject([Color.red, .blue, .green, .yellow, .gray])
    var colorsSequence: AnyAsyncSequence<[Color]> {
        colorsSubject.eraseToAnyAsyncSequence()
    }

    init() {
        // Doesn't work:
        // withAnimation(.bouncy.delay(1)) {
        //     colorsSubject.send([.green, .yellow, .gray])
        // }

        // Doesn't work with the previous solution, but now works:
        colorsSubject.send([.green, .yellow, .gray])
    }
}

struct StateView: View {
    @State private var colors: [Color] = [.red, .blue, .green, .yellow, .gray]

    var body: some View {
        ListView(colors: colors)
            .onAppear {
                withAnimation(.bouncy.delay(1)) {
                    colors = [.green, .yellow, .gray]
                }
            }
    }
}

struct AsyncBindingView: View {
    // Previous solution: doesn't work
    // @AsyncBinding private var colors: [Color] = [.red, .blue, .green, .yellow, .gray]

    // New solution, works
    @AsyncBinding(animation: .bouncy.delay(1)) private var colors: [Color] = [.red, .blue, .green, .yellow, .gray]

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ListView(colors: colors)
            .bind {
                viewModel.colorsSequence.assign(to: $colors)
            }
    }
}

struct ListView: View {
    let colors: [Color]

    var body: some View {
        ScrollView {
            VStack {
                ForEach(colors, id: \.self, content: RectangleView.init)
            }
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

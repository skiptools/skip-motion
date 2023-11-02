// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import OSLog
import SwiftUI
#if !SKIP
import Lottie
#else
import com.airbnb.lottie.__
import com.airbnb.lottie.compose.__
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxSize
#endif
import Foundation

let logger: Logger = Logger(subsystem: "SkipMotion", category: "MotionView")

/// A MotionView embeds an animation in the Lottie JSON format.
public struct MotionView : View {
    let lottieData: Data

    public init(lottie lottieData: Data) {
        self.lottieData = lottieData
    }

    public var body: some View {
        try! LottieMotionView(lottie: lottieData)
        #if SKIP
        .Compose(composectx)
        #endif
    }
}

private struct LottieMotionView : View {
    #if !SKIP
    let lottieAnimation: LottieAnimation
    #else
    let lottieComposition: LottieComposition
    #endif

    /// Creates a MotionView with the data represented by the given Lottie JSON.
    init(lottie lottieData: Data) throws {
        #if !SKIP
        self.lottieAnimation = try LottieAnimation.from(data: lottieData)
        #else
        self.lottieComposition = try LottieCompositionFactory.fromJsonInputStreamSync(lottieData.platformData.inputStream(), nil).getValue()!
        #endif
    }

    #if !SKIP
    var body: some View {
        LottieView(animation: self.lottieAnimation)
            .resizable()
            .playing(loopMode: .loop)
    }
    #else
    @Composable override func ComposeContent(context: ComposeContext) {
        let contentContext = context.content()
        ComposeContainer(modifier: context.modifier) { modifier in
            LottieAnimation(self.lottieComposition,
                            modifier: modifier.fillMaxSize(),
                            iterations: LottieConstants.IterateForever)
        }
    }
    #endif
}

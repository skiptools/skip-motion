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
        try! LottieMotionView(container: LottieContainer(data: lottieData))
        #if SKIP
        .Compose(composectx)
        #endif
    }
}

struct LottieMotionView : View {
    let container: LottieContainer

    #if !SKIP
    var body: some View {
        LottieView(animation: container.lottieAnimation)
            .resizable()
            .playing(loopMode: .loop)
    }
    #else
    @Composable override func ComposeContent(context: ComposeContext) {
        let contentContext = context.content()
        ComposeContainer(modifier: context.modifier) { modifier in
            LottieAnimation(container.lottieComposition,
                            modifier: modifier.fillMaxSize(),
                            iterations: LottieConstants.IterateForever)
        }
    }
    #endif
}

/// A container for Lottie JSON data.
///
/// In Swift, this wraps a `Lottie.LottieAnimation` and on Android it wraps a `com.airbnb.lottie.LottieComposition`.
public struct LottieContainer {
    #if !SKIP
    let lottieAnimation: LottieAnimation
    #else
    let lottieComposition: LottieComposition
    #endif

    /// Creates a MotionView with the data represented by the given Lottie JSON.
    public init(data lottieData: Data) throws {
        #if !SKIP
        self.lottieAnimation = try LottieAnimation.from(data: lottieData)
        #else
        let compositionResult = try LottieCompositionFactory.fromJsonInputStreamSync(lottieData.platformData.inputStream(), nil)

        guard let composition = compositionResult.getValue() else {
            throw compositionResult.getException() ?? IllegalArgumentException("Unable to load composition from data")
        }
        self.lottieComposition = composition
        #endif
    }

    public var duration: TimeInterval {
        #if !SKIP
        lottieAnimation.duration
        #else
        lottieComposition.duration.toDouble() / 1000.0 // kotlin.Float milliseconds
        #endif
    }

    public var startFrame: CGFloat {
        #if !SKIP
        lottieAnimation.startFrame
        #else
        lottieComposition.startFrame.toDouble()
        #endif
    }

    public var endFrame: CGFloat {
        #if !SKIP
        lottieAnimation.endFrame
        #else
        lottieComposition.endFrame.toDouble()
        #endif
    }

    public var bounds: CGRect {
        #if !SKIP
        lottieAnimation.bounds
        #else
        let rect: android.graphics.Rect = lottieComposition.bounds
        return CGRect(x: rect.left, y: rect.top, width: rect.right, height: rect.bottom)
        #endif
    }
}

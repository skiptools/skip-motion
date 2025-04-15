// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
//#if !SKIP_BRIDGE
import Foundation
#if SKIP_BRIDGE
import SkipFuseUI
#else
#if canImport(OSLog)
import OSLog
#endif
#if canImport(SkipFuseUI) || SKIP
import SkipFuseUI
#else
import SwiftUI
#endif

#if !SKIP
import Lottie
#else
import com.airbnb.lottie.__
import com.airbnb.lottie.compose.__
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxSize
#endif // !SKIP
#endif // SKIP_BRIDGE

let logger: Logger = Logger(subsystem: "skip.motion", category: "MotionView")

/// A MotionView embeds an animation in the Lottie JSON format.
public struct MotionView : View {
    let lottieData: Data

    public init(lottie lottieData: Data) {
        self.lottieData = lottieData
    }

    public var body: some View {
        #if SKIP_BRIDGE && os(Android)
        ComposeView {
            MotionComposer(lottieData: lottieData)
        }
        #else
        try! LottieMotionView(container: LottieContainer(data: lottieData))
        #if SKIP
        .Compose(composectx)
        #endif
        #endif
    }
}

#if !SKIP_BRIDGE
#if !os(Android)

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
#endif // !os(Android)
#endif // !SKIP_BRIDGE

#if SKIP
/// Use a ContentComposer to integrate Compose content. This code will be transpiled to Kotlin.
struct MotionComposer : ContentComposer {
    let lottieData: Data

    @Composable func Compose(context: ComposeContext) {
        //androidx.compose.material3.Text("💚", modifier: context.modifier)

        // FIXME: would like to use a NON-BRIDGED LottieContainer here…
        // let container = LottieContainer(data: lottieData)

        let compositionResult = try LottieCompositionFactory.fromJsonInputStreamSync(lottieData.platformData.inputStream(), nil)

        guard let composition = compositionResult.getValue() else {
            throw compositionResult.getException() ?? IllegalArgumentException("Unable to load composition from data")
        }

        let contentContext = context.content()
        ComposeContainer(modifier: context.modifier) { modifier in
            LottieAnimation(composition,
                            modifier: modifier.fillMaxSize(),
                            iterations: LottieConstants.IterateForever)
        }
    }

}
#endif

#if !SKIP_BRIDGE
/// A container for Lottie data, which is an After Effects/Bodymovin JSON composition model.
///
/// This is the serialized model from which the animation will be created. It is designed to be stateless, cacheable, and shareable.
/// The format is described at [https://lottie.github.io/lottie-spec/](https://lottie.github.io/lottie-spec/).
///
/// In Swift, this wraps a `Lottie.LottieAnimation` and on Android it wraps a `com.airbnb.lottie.LottieComposition`.
/* SKIP @nobridge */public final class LottieContainer {
    #if !SKIP
    let lottieAnimation: LottieAnimation
    #else
    let lottieComposition: LottieComposition
    #endif

    /// Creates a Lottie container with the data represented by the given Lottie JSON.
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

    // SKIP @nobridge
    public var bounds: CGRect {
        #if !SKIP
        lottieAnimation.bounds
        #else
        let rect: android.graphics.Rect = lottieComposition.bounds
        let x: Int = rect.left
        let y: Int = rect.top
        let width: Int = rect.right - x
        let height: Int = rect.bottom - y
        return CGRect(x: x, y: y, width: width, height: height)
        #endif
    }
}
#endif
//#endif

// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
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

let logger: Logger = Logger(subsystem: "SkipMotion", category: "MotionView")

/// Defines animation loop behavior.
public enum MotionLoopMode: Hashable, Sendable {
    /// Animation is played once then stops.
    case playOnce
    /// Animation will loop from beginning to end until stopped.
    case loop
    /// Animation will play forward, then backwards and loop until stopped.
    case autoReverse
    /// Animation will loop from beginning to end up to defined amount of times.
    case `repeat`(Int)
    /// Animation will play forward, then backwards a defined amount of times.
    case repeatBackwards(Int)
}

/// A MotionView embeds an animation in the Lottie JSON format.
public struct MotionView : View {
    let lottieContainer: LottieContainer?
    let animationSpeed: Double
    let loopMode: MotionLoopMode
    let isPlaying: Bool

    public init(lottie lottieData: Data, animationSpeed: Double = 1.0, loopMode: MotionLoopMode = .loop, isPlaying: Bool = true) {
        var lottieContainer: LottieContainer? = nil
        do {
            lottieContainer = try LottieContainer(data: lottieData)
        } catch {
            logger.error("Unable to parse Lottie data: \(error)")
        }
        self.lottieContainer = lottieContainer
        self.animationSpeed = animationSpeed
        self.loopMode = loopMode
        self.isPlaying = isPlaying
    }

    public init(lottie lottieContainer: LottieContainer, animationSpeed: Double = 1.0, loopMode: MotionLoopMode = .loop, isPlaying: Bool = true) {
        self.lottieContainer = lottieContainer
        self.animationSpeed = animationSpeed
        self.loopMode = loopMode
        self.isPlaying = isPlaying
    }

    #if !SKIP
    private var lottieLoopMode: LottieLoopMode {
        switch loopMode {
        case .playOnce:
            return .playOnce
        case .loop:
            return .loop
        case .autoReverse:
            return .autoReverse
        case .repeat(let count):
            return .repeat(Float(count))
        case .repeatBackwards(let count):
            return .repeatBackwards(Float(count))
        }
    }

    public var body: some View {
        if let lottieContainer {
            if isPlaying {
                LottieView(animation: lottieContainer.lottieAnimation)
                    .resizable()
                    .playing(loopMode: lottieLoopMode)
                    .animationSpeed(animationSpeed)
            } else {
                LottieView(animation: lottieContainer.lottieAnimation)
                    .resizable()
                    .paused()
                    .animationSpeed(animationSpeed)
            }
        }
    }
    #else
    // SKIP @nobridge
    private var iterations: Int {
        switch loopMode {
        case .playOnce:
            return 1
        case .loop, .autoReverse:
            return LottieConstants.IterateForever
        case .repeat(let count):
            return count
        case .repeatBackwards(let count):
            return count
        }
    }

    // SKIP @nobridge
    private var reverseOnRepeat: Bool {
        switch loopMode {
        case .autoReverse:
            return true
        case .repeatBackwards:
            return true
        default:
            return false
        }
    }

    // SKIP @nobridge
    @Composable override func ComposeContent(context: ComposeContext) {
        guard let lottieContainer else {
            return
        }
        let contentContext = context.content()
        ComposeContainer(modifier: context.modifier) { modifier in
            LottieAnimation(lottieContainer.lottieComposition,
                            modifier: modifier.fillMaxSize(),
                            isPlaying: isPlaying,
                            iterations: iterations,
                            speed: animationSpeed.toFloat(),
                            reverseOnRepeat: reverseOnRepeat)
        }
    }
    #endif
}

/// A container for Lottie data, which is an After Effects/Bodymovin JSON composition model.
///
/// This is the serialized model from which the animation will be created. It is designed to be stateless, cacheable, and shareable.
/// The format is described at [https://lottie.github.io/lottie-spec/](https://lottie.github.io/lottie-spec/).
///
/// In Swift, this wraps a `Lottie.LottieAnimation` and on Android it wraps a `com.airbnb.lottie.LottieComposition`.
public struct LottieContainer : Sendable {
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

    public var framerate: Double {
        #if !SKIP
        lottieAnimation.framerate
        #else
        lottieComposition.getFrameRate().toDouble()
        #endif
    }

    public var width: Double {
        bounds.width
    }

    public var height: Double {
        bounds.height
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

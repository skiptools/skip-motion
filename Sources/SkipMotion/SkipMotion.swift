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
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.layout.ContentScale
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

/// Defines how the animation content is scaled within its bounds.
public enum MotionContentMode: Hashable, Sendable {
    /// Scale the animation to fit within the bounds while preserving aspect ratio.
    case fit
    /// Scale the animation to fill the bounds while preserving aspect ratio, cropping if needed.
    case fill
}

/// A MotionView embeds an animation in the Lottie JSON format.
public struct MotionView : View {
    let lottieContainer: LottieContainer?
    let animationSpeed: Double
    let loopMode: MotionLoopMode
    let isPlaying: Bool
    let contentMode: MotionContentMode
    let currentProgress: Double?
    let fromProgress: Double?
    let toProgress: Double?
    let enableMergePaths: Bool
    let currentFrame: CGFloat?
    let onComplete: ((Bool) -> Void)?

    public init(lottie lottieData: Data, animationSpeed: Double = 1.0, loopMode: MotionLoopMode = .loop, isPlaying: Bool = true, contentMode: MotionContentMode = .fit, currentProgress: Double? = nil, fromProgress: Double? = nil, toProgress: Double? = nil, enableMergePaths: Bool = false, currentFrame: CGFloat? = nil, onComplete: ((Bool) -> Void)? = nil) {
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
        self.contentMode = contentMode
        self.currentProgress = currentProgress
        self.fromProgress = fromProgress
        self.toProgress = toProgress
        self.enableMergePaths = enableMergePaths
        self.currentFrame = currentFrame
        self.onComplete = onComplete
    }

    public init(lottie lottieContainer: LottieContainer, animationSpeed: Double = 1.0, loopMode: MotionLoopMode = .loop, isPlaying: Bool = true, contentMode: MotionContentMode = .fit, currentProgress: Double? = nil, fromProgress: Double? = nil, toProgress: Double? = nil, enableMergePaths: Bool = false, currentFrame: CGFloat? = nil, onComplete: ((Bool) -> Void)? = nil) {
        self.lottieContainer = lottieContainer
        self.animationSpeed = animationSpeed
        self.loopMode = loopMode
        self.isPlaying = isPlaying
        self.contentMode = contentMode
        self.currentProgress = currentProgress
        self.fromProgress = fromProgress
        self.toProgress = toProgress
        self.enableMergePaths = enableMergePaths
        self.currentFrame = currentFrame
        self.onComplete = onComplete
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

    private var playbackState: LottiePlaybackMode {
        if isPlaying {
            if let from = fromProgress, let to = toProgress, from < to {
                return .playing(.fromProgress(from, toProgress: to, loopMode: lottieLoopMode))
            } else {
                return .playing(.toProgress(1, loopMode: lottieLoopMode))
            }
        } else if let progress = currentProgress {
            return .paused(at: .progress(progress))
        } else if let frame = currentFrame {
            return .paused(at: .frame(frame))
        } else {
            return .paused
        }
    }

    public var body: some View {
        if let lottieContainer {
            LottieView(animation: lottieContainer.lottieAnimation)
                .playbackMode(playbackState)
                .animationSpeed(animationSpeed)
                .animationDidFinishOptional(onComplete)
                .resizable()
                .scaledToFillOptional(contentMode == .fill)
        }
    }
    #else
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

    private var composeContentScale: ContentScale {
        switch contentMode {
        case .fit:
            return ContentScale.Fit
        case .fill:
            return ContentScale.Crop
        }
    }

    private var clipSpec: LottieClipSpec? {
        if let from = fromProgress, let to = toProgress, from < to {
            return LottieClipSpec.Progress(min: from.toFloat(), max: to.toFloat())
        }
        return nil
    }
    
    // SKIP @nobridge
    @Composable override func ComposeContent(context: ComposeContext) {
        guard let lottieContainer else {
            return
        }
        let contentContext = context.content()
        ComposeContainer(modifier: context.modifier) { modifier in
            if !isPlaying, let progress = currentProgress {
                // When paused with a specific progress, use the progress-based overload
                LottieAnimation(lottieContainer.lottieComposition,
                                progress: { progress.toFloat() },
                                modifier: modifier.fillMaxSize(),
                                contentScale: composeContentScale,
                                enableMergePaths: enableMergePaths)
            } else if !isPlaying, let frame = currentFrame {
                // When paused with a specific frame, convert to progress
                let frameProgress = lottieContainer.lottieComposition.getProgressForFrame(frame.toFloat())
                LottieAnimation(lottieContainer.lottieComposition,
                                progress: { frameProgress },
                                modifier: modifier.fillMaxSize(),
                                contentScale: composeContentScale,
                                enableMergePaths: enableMergePaths)
            } else if let onComplete = onComplete {
                // Use animateLottieCompositionAsState to track completion
                let animationState = animateLottieCompositionAsState(
                    composition: lottieContainer.lottieComposition,
                    isPlaying: isPlaying,
                    iterations: iterations,
                    speed: animationSpeed.toFloat(),
                    reverseOnRepeat: reverseOnRepeat,
                    clipSpec: clipSpec
                )

                // Track previous playing state to detect completion
                let wasPlaying = remember { mutableStateOf(false) }
                LaunchedEffect(animationState.isPlaying, animationState.isAtEnd) {
                    if wasPlaying.value && !animationState.isPlaying {
                        // Animation stopped - finished=true if at end, false if interrupted
                        onComplete(animationState.isAtEnd)
                    }
                    wasPlaying.value = animationState.isPlaying
                }

                LottieAnimation(lottieContainer.lottieComposition,
                                progress: { animationState.progress },
                                modifier: modifier.fillMaxSize(),
                                contentScale: composeContentScale,
                                enableMergePaths: enableMergePaths)
            } else {
                // Normal animated playback (with optional clip spec)
                LottieAnimation(lottieContainer.lottieComposition,
                                modifier: modifier.fillMaxSize(),
                                isPlaying: isPlaying,
                                iterations: iterations,
                                speed: animationSpeed.toFloat(),
                                reverseOnRepeat: reverseOnRepeat,
                                clipSpec: clipSpec,
                                contentScale: composeContentScale,
                                enableMergePaths: enableMergePaths)
            }
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

#if !SKIP
private extension LottieView {
    func animationDidFinishOptional(_ handler: ((Bool) -> Void)?) -> Self {
        if let handler {
            return self.animationDidFinish { finished in handler(finished) }
        } else {
            return self
        }
    }
}

private extension View {
    @ViewBuilder
    func scaledToFillOptional(_ condition: Bool) -> some View {
        if condition {
            self.scaledToFill()
        } else {
            self
        }
    }
}
#endif
#endif

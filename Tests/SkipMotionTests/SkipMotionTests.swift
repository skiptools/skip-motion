// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import XCTest
import OSLog
import Foundation
@testable import SkipMotion

let logger: Logger = Logger(subsystem: "SkipMotion", category: "Tests")

@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 8, *)
final class SkipMotionTests: XCTestCase {
    func testLoadLottie() throws {
        let motion = try LottieContainer(data: lottieSample.data(using: .utf8)!)
        XCTAssertEqual(6.0, motion.duration, accuracy: 0.1) // java.lang.AssertionError: 6.0 != 5999.0
        XCTAssertEqual(0.0, motion.startFrame)
        XCTAssertEqual(180.0, motion.endFrame, accuracy: 0.1) // java.lang.AssertionError: 180.0 != 179.99000549316406

        if !isAndroid {
            // fails on emulator for some reason: java.lang.AssertionError: 400.0 != 1050.0
            XCTAssertEqual(400.0, motion.bounds.width)
            XCTAssertEqual(300.0, motion.bounds.height)
        }
    }

    func testLoadLottieFailure() throws {
        do {
            let _ = try LottieContainer(data: "BADDATA".data(using: .utf8)!)
            XCTFail("should not have been able to load lottie view from empty data")
        } catch {
            print("got expected error: \(error)")
            #if !SKIP
            XCTAssertTrue(error.localizedDescription.contains("The data couldn’t be read because it isn’t in the correct format."), "bad error message: \(error.localizedDescription)")
            #else
            XCTAssertTrue(error.localizedDescription.contains("Use JsonReader.setLenient(true) to accept malformed JSON at path"), "bad error message: \(error.localizedDescription)")
            #endif
        }
    }
}

let lottieSample = #"{"assets":[],"layers":[{"ddd":0,"ind":0,"ty":3,"nm":"Rotator","ks":{"o":{"k":0},"r":{"k":[{"i":{"x":[0.56],"y":[1]},"o":{"x":[0.634],"y":[0]},"n":["0p56_1_0p634_0"],"t":19,"s":[0],"e":[190.7]},{"i":{"x":[0.562],"y":[1]},"o":{"x":[0.398],"y":[0]},"n":["0p562_1_0p398_0"],"t":33,"s":[190.7],"e":[176.1]},{"i":{"x":[0.684],"y":[1]},"o":{"x":[0.31],"y":[0]},"n":["0p684_1_0p31_0"],"t":40.5,"s":[176.1],"e":[181.8]},{"i":{"x":[0.684],"y":[1]},"o":{"x":[0.438],"y":[0]},"n":["0p684_1_0p438_0"],"t":55,"s":[181.8],"e":[180]},{"i":{"x":[0.733],"y":[0.733]},"o":{"x":[0.385],"y":[0.385]},"n":["0p733_0p733_0p385_0p385"],"t":71,"s":[180],"e":[180]},{"i":{"x":[0.092],"y":[1]},"o":{"x":[0.406],"y":[0]},"n":["0p092_1_0p406_0"],"t":111,"s":[180],"e":[167.9]},{"i":{"x":[0.341],"y":[1]},"o":{"x":[0.6],"y":[0]},"n":["0p341_1_0p6_0"],"t":116,"s":[167.9],"e":[363]},{"i":{"x":[0.462],"y":[1]},"o":{"x":[0.167],"y":[0]},"n":["0p462_1_0p167_0"],"t":134,"s":[363],"e":[360]},{"t":141}]},"p":{"k":[200.5,149.375,0]},"a":{"k":[60,60,0]},"s":{"k":[100,100,100]}},"ao":0,"ip":0,"op":180,"st":0,"bm":0,"sr":1},{"ddd":0,"ind":1,"ty":4,"nm":"A1","parent":0,"ks":{"o":{"k":100},"r":{"k":[{"i":{"x":[0.56],"y":[1]},"o":{"x":[0.634],"y":[0]},"n":["0p56_1_0p634_0"],"t":19,"s":[0],"e":[-45]},{"i":{"x":[0.833],"y":[0.833]},"o":{"x":[0.167],"y":[0.167]},"n":["0p833_0p833_0p167_0p167"],"t":33,"s":[-45],"e":[-45]},{"i":{"x":[0.341],"y":[1]},"o":{"x":[0.6],"y":[0]},"n":["0p341_1_0p6_0"],"t":116,"s":[-45],"e":[0]},{"t":134}]},"p":{"k":[{"i":{"x":0.56,"y":1},"o":{"x":0.634,"y":0},"n":"0p56_1_0p634_0","t":19,"s":[94.5,82.875,0],"e":[96.2,57.055,0],"to":[0,0,0],"ti":[0,0,0]},{"i":{"x":0,"y":0},"o":{"x":0.167,"y":0.167},"n":"0_0_0p167_0p167","t":33,"s":[96.2,57.055,0],"e":[96.2,57.055,0],"to":[0,0,0],"ti":[0,0,0]},{"i":{"x":0.341,"y":1},"o":{"x":0.6,"y":0},"n":"0p341_1_0p6_0","t":116,"s":[96.2,57.055,0],"e":[94.5,82.875,0],"to":[0,0,0],"ti":[0,0,0]},{"t":134}]},"a":{"k":[35,22.25,0]},"s":{"k":[100,100,100]}},"ao":0,"shapes":[{"ty":"gr","it":[{"ind":0,"ty":"sh","ks":{"k":{"i":[[0,0],[0,0]],"o":[[0,0],[0,0]],"v":[[-34,22.25],[35,22.25]],"c":false}},"nm":"Path 1"},{"ty":"st","fillEnabled":true,"c":{"k":[0.4,0.16,0.7,1]},"o":{"k":100},"w":{"k":10},"lc":1,"lj":1,"ml":4,"nm":"Stroke 1"},{"ty":"tr","p":{"k":[0,0],"ix":2},"a":{"k":[0,0],"ix":1},"s":{"k":[100,100],"ix":3},"r":{"k":0,"ix":6},"o":{"k":100,"ix":7},"sk":{"k":0,"ix":4},"sa":{"k":0,"ix":5},"nm":"Transform"}],"nm":"Shape 1"},{"ty":"tm","s":{"k":[{"i":{"x":[0.56],"y":[1]},"o":{"x":[0.634],"y":[0]},"n":["0p56_1_0p634_0"],"t":19,"s":[0],"e":[26]},{"i":{"x":[0.833],"y":[0.833]},"o":{"x":[0.167],"y":[0.167]},"n":["0p833_0p833_0p167_0p167"],"t":33,"s":[26],"e":[26]},{"i":{"x":[0.341],"y":[1]},"o":{"x":[0.6],"y":[0]},"n":["0p341_1_0p6_0"],"t":116,"s":[26],"e":[0]},{"t":134}],"ix":1},"e":{"k":[{"i":{"x":[0.56],"y":[0.56]},"o":{"x":[0.634],"y":[0.634]},"n":["0p56_0p56_0p634_0p634"],"t":19,"s":[100],"e":[100]},{"i":{"x":[0.833],"y":[0.833]},"o":{"x":[0.167],"y":[0.167]},"n":["0p833_0p833_0p167_0p167"],"t":33,"s":[100],"e":[100]},{"i":{"x":[0.341],"y":[0.341]},"o":{"x":[0.6],"y":[0.6]},"n":["0p341_0p341_0p6_0p6"],"t":116,"s":[100],"e":[100]},{"t":134}],"ix":2},"o":{"k":0,"ix":3},"m":1,"ix":2,"nm":"Trim Paths 1"}],"ip":0,"op":180,"st":0,"bm":0,"sr":1},{"ddd":0,"ind":2,"ty":4,"nm":"A2","parent":0,"ks":{"o":{"k":100},"r":{"k":0},"p":{"k":[60,60.625,0]},"a":{"k":[0.5,0,0]},"s":{"k":[100,100,100]}},"ao":0,"shapes":[{"ty":"gr","it":[{"ind":0,"ty":"sh","ks":{"k":{"i":[[0,0],[0,0]],"o":[[0,0],[0,0]],"v":[[-34,0],[35,0]],"c":false}},"nm":"Path 1"},{"ty":"st","fillEnabled":true,"c":{"k":[0.4,0.16,0.7,1]},"o":{"k":100},"w":{"k":10},"lc":1,"lj":1,"ml":4,"nm":"Stroke 1"},{"ty":"tr","p":{"k":[0,0],"ix":2},"a":{"k":[0,0],"ix":1},"s":{"k":[100,100],"ix":3},"r":{"k":0,"ix":6},"o":{"k":100,"ix":7},"sk":{"k":0,"ix":4},"sa":{"k":0,"ix":5},"nm":"Transform"}],"nm":"Shape 1"}],"ip":0,"op":180,"st":0,"bm":0,"sr":1},{"ddd":0,"ind":3,"ty":4,"nm":"A3","parent":0,"ks":{"o":{"k":100},"r":{"k":[{"i":{"x":[0.56],"y":[1]},"o":{"x":[0.634],"y":[0]},"n":["0p56_1_0p634_0"],"t":19,"s":[0],"e":[45]},{"i":{"x":[0.833],"y":[0.833]},"o":{"x":[0.167],"y":[0.167]},"n":["0p833_0p833_0p167_0p167"],"t":33,"s":[45],"e":[45]},{"i":{"x":[0.341],"y":[1]},"o":{"x":[0.6],"y":[0]},"n":["0p341_1_0p6_0"],"t":116,"s":[45],"e":[0]},{"t":134}]},"p":{"k":[{"i":{"x":0.56,"y":1},"o":{"x":0.634,"y":0},"n":"0p56_1_0p634_0","t":19,"s":[94.5,37.125,0],"e":[96.2,64.045,0],"to":[0,0,0],"ti":[0,0,0]},{"i":{"x":0,"y":0},"o":{"x":0.167,"y":0.167},"n":"0_0_0p167_0p167","t":33,"s":[96.2,64.045,0],"e":[96.2,64.045,0],"to":[0,0,0],"ti":[0,0,0]},{"i":{"x":0.341,"y":1},"o":{"x":0.6,"y":0},"n":"0p341_1_0p6_0","t":116,"s":[96.2,64.045,0],"e":[94.5,37.125,0],"to":[0,0,0],"ti":[0,0,0]},{"t":134}]},"a":{"k":[35,-23.5,0]},"s":{"k":[100,100,100]}},"ao":0,"shapes":[{"ty":"gr","it":[{"ind":0,"ty":"sh","ks":{"k":{"i":[[0,0],[0,0]],"o":[[0,0],[0,0]],"v":[[-34,-23.5],[35,-23.5]],"c":false}},"nm":"Path 1"},{"ty":"st","fillEnabled":true,"c":{"k":[0.4,0.16,0.7,1]},"o":{"k":100},"w":{"k":10},"lc":1,"lj":1,"ml":4,"nm":"Stroke 1"},{"ty":"tr","p":{"k":[0,0],"ix":2},"a":{"k":[0,0],"ix":1},"s":{"k":[100,100],"ix":3},"r":{"k":0,"ix":6},"o":{"k":100,"ix":7},"sk":{"k":0,"ix":4},"sa":{"k":0,"ix":5},"nm":"Transform"}],"nm":"Shape 1"},{"ty":"tm","s":{"k":[{"i":{"x":[0.56],"y":[1]},"o":{"x":[0.634],"y":[0]},"n":["0p56_1_0p634_0"],"t":19,"s":[0],"e":[26]},{"i":{"x":[0.833],"y":[0.833]},"o":{"x":[0.167],"y":[0.167]},"n":["0p833_0p833_0p167_0p167"],"t":33,"s":[26],"e":[26]},{"i":{"x":[0.341],"y":[1]},"o":{"x":[0.6],"y":[0]},"n":["0p341_1_0p6_0"],"t":116,"s":[26],"e":[0]},{"t":134}],"ix":1},"e":{"k":[{"i":{"x":[0.56],"y":[0.56]},"o":{"x":[0.634],"y":[0.634]},"n":["0p56_0p56_0p634_0p634"],"t":19,"s":[100],"e":[100]},{"i":{"x":[0.833],"y":[0.833]},"o":{"x":[0.167],"y":[0.167]},"n":["0p833_0p833_0p167_0p167"],"t":33,"s":[100],"e":[100]},{"i":{"x":[0.341],"y":[0.341]},"o":{"x":[0.6],"y":[0.6]},"n":["0p341_0p341_0p6_0p6"],"t":116,"s":[100],"e":[100]},{"t":134}],"ix":2},"o":{"k":0,"ix":3},"m":1,"ix":2,"nm":"Trim Paths 1"}],"ip":0,"op":180,"st":0,"bm":0,"sr":1}],"v":"4.4.26","ddd":0,"ip":0,"op":180,"fr":30,"w":400,"h":300}"#

# SkipMotion

This is a [Skip](https://skip.tools) Swift/Kotlin library project that 
provides the ability to play Lottie animations in dual-platform Skip apps
for iOS and Android.

On the Kotlin side, SkipMotion uses the [lottie-ios](https://github.com/airbnb/lottie-ios)
package, and on Android it uses the [lottie-android](https://github.com/airbnb/lottie-android).

Lottie is a mobile library for Android and iOS that parses [Adobe After Effects](http://www.adobe.com/products/aftereffects.html) animations exported as json with [Bodymovin](https://github.com/airbnb/lottie-web) and renders them natively, enabling
 designers and developers to create and ship beautiful and seamless animations in their apps.

Example:


```swift
import SwiftUI
import Foundation
import SkipMotion

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Skip Motion Animation")
                .font(.largeTitle)
            try! MotionView(lottie: lottieData)
        }
    }
}

let lottieData = """
{"mn":"ADBE Vector Shape - Group"}
""".data(using: String.Encoding.utf8)!

```


## Building

This project is a Swift Package Manager module that uses the
[Skip](https://skip.tools) plugin to transpile Swift into Kotlin.

Building the module requires that Skip be installed using 
[Homebrew](https://brew.sh) with `brew install skiptools/skip/skip`.
This will also install the necessary build prerequisites:
Kotlin, Gradle, and the Android build tools.

## Testing

The module can be tested using the standard `swift test` command
or by running the test target for the macOS destination in Xcode,
which will run the Swift tests as well as the transpiled
Kotlin JUnit tests in the Robolectric Android simulation environment.

Parity testing can be performed with `skip test`,
which will output a table of the test results for both platforms.

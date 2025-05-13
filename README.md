# SkipMotion

This is a [Skip](https://skip.tools) Swift/Kotlin library project that 
provides the ability to play Lottie animations in dual-platform Skip apps
for iOS and Android.

<video id="intro_video" style="width: 100%" controls autoplay>
  <source style="width: 100;" src="https://assets.skip.tools/videos/SkipMotionExample.mov" type="video/mp4">
  Your browser does not support the video tag.
</video>

On the Kotlin side, SkipMotion uses the [lottie-ios](https://github.com/airbnb/lottie-ios)
package, and on Android it uses the [lottie-android](https://github.com/airbnb/lottie-android).

Lottie is a mobile library for Android and iOS that parses [Adobe After Effects](http://www.adobe.com/products/aftereffects.html) animations exported as json with [Bodymovin](https://github.com/airbnb/lottie-web) and renders them natively, enabling
 designers and developers to create and ship beautiful and seamless animations in their apps.

Example:


```swift
import Foundation
import SkipFuseUI
import SkipMotion

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Skip Motion Animation")
                .font(.largeTitle)
            MotionView(lottie: lottieData)
        }
    }
}

let lottieData = """
{"mn":"ADBE Vector Shape - Group"}
""".data(using: String.Encoding.utf8)!
```

## Status

SkipMotion is in a very early stage, and lack any playback
controls or other customization of the animations.

You are encouraged to contribute to the project or
file an [issue](https://source.skip.tools/skip-motion/issues)
with needs and requests.

## Size

Adding `SkipMotion` as a dependency will add around 1MB to the
size of the release `.ipa` and `.apk` artifacts for your project.

## Example

See the [LottieDemo](https://source.skip.tools/skipapp-lottiedemo/releases)
project for an example of using `SkipMotion` in a Skip App project.

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

## Contributing

We welcome contributions to this package in the form of enhancements and bug fixes.

The general flow for contributing to this and any other Skip package is:

1. Fork this repository and enable actions from the "Actions" tab
2. Check out your fork locally
3. When developing alongside a Skip app, add the package to a [shared workspace](https://skip.tools/docs/contributing) to see your changes incorporated in the app
4. Push your changes to your fork and ensure the CI checks all pass in the Actions tab
5. Add your name to the Skip [Contributor Agreement](https://github.com/skiptools/clabot-config)
6. Open a Pull Request from your fork with a description of your changes

## License

This software is licensed under the
[GNU Lesser General Public License v3.0](https://spdx.org/licenses/LGPL-3.0-only.html),
with the following
[linking exception](https://spdx.org/licenses/LGPL-3.0-linking-exception.html)
to clarify that distribution to restricted environments (e.g., app stores)
is permitted:

> This software is licensed under the LGPL3, included below.
> As a special exception to the GNU Lesser General Public License version 3
> ("LGPL3"), the copyright holders of this Library give you permission to
> convey to a third party a Combined Work that links statically or dynamically
> to this Library without providing any Minimal Corresponding Source or
> Minimal Application Code as set out in 4d or providing the installation
> information set out in section 4e, provided that you comply with the other
> provisions of LGPL3 and provided that you meet, for the Application the
> terms and conditions of the license(s) which apply to the Application.
> Except as stated in this special exception, the provisions of LGPL3 will
> continue to comply in full to this Library. If you modify this Library, you
> may apply this exception to your version of this Library, but you are not
> obliged to do so. If you do not wish to do so, delete this exception
> statement from your version. This exception does not (and cannot) modify any
> license terms which apply to the Application, with which you must still
> comply.


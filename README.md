# LSLogViewer
**LSLogViewer** is a simple in-app log viewer. It allows saving logs to files and reading them inside your application.

## Note
In version 1.x the purpose of this library was to read logs saved by NSLog on the device however as this is not longer possible on recent iOS version now this library saves logs to own files in Documents directory and read those files.
<p align="center" >
<img src="https://raw.github.com/leszek-s/LSLogViewer/master/LSLogViewerSample/lslogviewer.gif" alt="LSLogViewer" width="320" height="568" />
</p>

## Usage
To log something use LSLog instead of NSLog like below (or LSLogl if you use this library from Swift code). This will save your logs to files in documents directory of the application.

```objc
LSLog(@"Hello!");
```

To present the LSLogViewer screen that allows reading logs simply call it anywhere from your code like below.

```objc
[LSLogViewer showViewer];
```

With a single line of code you can also register a three-finger triple-tap gesture which will open LSLogViewer without any additional code.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // setting UIWindow
    // ...
    [LSLogViewer registerThreeFingerTripleTapGesture];
    return YES;
}
```

## License
LSLogViewer is available under the MIT license. See [LICENSE](https://github.com/leszek-s/LSLogViewer/blob/master/LICENSE).

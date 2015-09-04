# LSLogViewer
**LSLogViewer** is a simple in-app log viewer. It allows reading logs saved by NSLog on iOS device.
<p align="center" >
<img src="https://raw.github.com/fins/LSLogViewer/master/LSLogViewerSample/lslogviewer.gif" alt="LSLogViewer" width="320" height="568" />
</p>
## Usage
To present the LSLogViewer screen simply call it anywhere from your code like below.
```objc
[LSLogViewer showViewer];
```
With a single line of code you can also register a three-finger triple-tap gesture which will open LSLogViewer without any additional code.
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ...
    [LSLogViewer registerThreeFingerTripleTapGesture];
    return YES;
}
```
## License
LSLogViewer is available under the MIT license. See [LICENSE](https://github.com/fins/LSLogViewer/blob/master/LICENSE).

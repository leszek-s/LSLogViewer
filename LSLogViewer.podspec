Pod::Spec.new do |s|
  s.name          = "LSLogViewer"
  s.version       = "1.0"
  s.summary       = "This is a simple in-app log viewer. It allows reading logs saved by NSLog on iOS device."
  s.homepage      = "https://github.com/fins/LSLogViewer"
  s.license       = "MIT"
  s.author        = "Leszek S"
  s.source        = { :git => "https://github.com/fins/LSLogViewer.git", :tag =>  "1.0" }
  s.platform      = :ios, "7.0"
  s.source_files  = "LSLogViewer"
  s.resources     = "LSLogViewer/LSLogViewer.xib"
  s.requires_arc  = true
end
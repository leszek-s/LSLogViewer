Pod::Spec.new do |s|
  s.name          = "LSLogViewer"
  s.version       = "2.0.2"
  s.summary       = "This is a simple in-app log viewer. It allows saving logs to files and reading them inside your application."
  s.homepage      = "https://github.com/leszek-s/LSLogViewer"
  s.license       = "MIT"
  s.author        = "Leszek S"
  s.source        = { :git => "https://github.com/leszek-s/LSLogViewer.git", :tag =>  "2.0.2" }
  s.platform      = :ios, "7.0"
  s.source_files  = "LSLogViewer"
  s.resources     = "LSLogViewer/LSLogViewer.xib"
  s.requires_arc  = true
end
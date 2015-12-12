#
# Be sure to run `pod lib lint PANetworkLog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PANetworkLog"
  s.version          = "0.1.0"
  s.summary          = "Simple library to send all NSLog messages to backend server."
  s.homepage         = "https://github.com/Pash237/PANetworkLog"
  s.license          = 'MIT'
  s.author           = { "Pavel Alexeev" => "pasha.alexeev@gmail.com" }
  s.source           = { :git => "https://github.com/Pash237/PANetworkLog.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'PANetworkLog/**/*'
end

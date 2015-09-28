Pod::Spec.new do |s|
  s.name     = 'DTModelStorage'
  s.version  = '2.0.1'
  s.license  = 'MIT'
  s.summary  = 'Storage classes for datasource based controls.'
  s.homepage = 'https://github.com/DenHeadless/DTModelStorage'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin@yandex.ru' }
  s.source   = { :git => 'https://github.com/DenHeadless/DTModelStorage.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.platform = :ios,'8.0'
  s.ios.deployment_target = '8.0'
  s.ios.frameworks = 'UIKit', 'Foundation', 'CoreData'
  s.source_files = 'DTModelStorage/**/*.{h,swift}'
end

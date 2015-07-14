Pod::Spec.new do |s|
  s.name     = 'DTModelStorage'
  s.version  = '1.3.0-beta2'
  s.license  = 'MIT'
  s.summary  = 'Storage classes for datasource based controls.'
  s.homepage = 'https://github.com/DenHeadless/DTModelStorage'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin@yandex.ru' }
  s.source   = { :git => 'https://github.com/DenHeadless/DTModelStorage.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.platform = :ios,'7.0'
  s.ios.frameworks = 'Foundation', 'CoreData'

  s.subspec 'ObjectiveC' do |ss|
    ss.source_files = 'DTModelStorage/ObjectiveC/**/*.{h,m}'
    ss.platform = :ios, 7.0
  end

  s.subspec 'Swift' do |ss|
    ss.source_files = 'DTModelStorage/Swift/**/*.swift'
    ss.platform = :ios, 8.0
  end

  s.default_subspec = 'Swift'
  
end
Pod::Spec.new do |s|
    s.name         = 'CJWKit'
    s.version      = '0.0.1'
    s.summary      = 'An easy way to program iOS APP'
    s.homepage     = 'https://github.com/CoderJoyWang/CJWKit'
    s.license      = 'MIT'
    s.authors      = {'JoyWang' => '644886889@qq.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/CoderJoyWang/CJWKit.git', :tag => s.version}
    s.source_files = 'CJWKit/*'
    s.requires_arc = true
end

require 'xcodeproj'

# 既存プロジェクトを削除
`rm -rf ScanSnapper.xcodeproj` if File.exist?('ScanSnapper.xcodeproj')

project = Xcodeproj::Project.new('ScanSnapper.xcodeproj')
target = project.new_target(:application, 'ScanSnapper', :osx, '12.0')

# Sources グループ作成（ディスク上のSourcesフォルダにリンク）
sources_group = project.main_group.new_group('Sources', 'Sources')

# ソースファイル追加（絶対パスではなく相対パスで）
['main.swift', 'AppDelegate.swift', 'SerialManager.swift', 'PasteService.swift'].each do |file|
  file_path = File.join('Sources', file)
  if File.exist?(file_path)
    file_ref = sources_group.new_reference(file)
    target.source_build_phase.add_file_reference(file_ref)
  else
    puts "⚠️  Warning: #{file_path} not found"
  end
end

# Assets & Info.plist
assets_path = 'Sources/Assets.xcassets'
if File.exist?(assets_path)
  assets = sources_group.new_reference('Assets.xcassets')
  target.resources_build_phase.add_file_reference(assets)
else
  puts "⚠️  Warning: #{assets_path} not found"
end

target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'Sources/Info.plist'
  config.build_settings['INFOPLIST_KEY_LSUIElement'] = 'YES'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.wonderdrill.ScanSnapperMac'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '12.0'
end

# ORSSerialPort パッケージ
package_ref = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
package_ref.repositoryURL = 'https://github.com/armadsen/ORSSerialPort.git'
package_ref.requirement = {
  kind: 'upToNextMajorVersion',
  minimumVersion: '2.1.0'
}
project.root_object.package_references << package_ref

product_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product_dep.product_name = 'ORSSerial'
product_dep.package = package_ref
target.package_product_dependencies << product_dep

project.save
puts "✅ ScanSnapper.xcodeproj created successfully"

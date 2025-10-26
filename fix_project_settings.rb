require 'xcodeproj'

project = Xcodeproj::Project.open('ScanSnapper.xcodeproj')
target = project.targets.first

puts "Fixing project settings for AppDelegate @main..."

target.build_configurations.each do |config|
  # Remove Main Interface (NSMainNibFile)
  config.build_settings.delete('INFOPLIST_KEY_NSMainNibFile')
  config.build_settings.delete('INFOPLIST_KEY_NSMainStoryboardFile')

  # Ensure Info.plist path is correct
  config.build_settings['INFOPLIST_FILE'] = 'Sources/Info.plist'

  # Ensure LSUIElement is set
  config.build_settings['INFOPLIST_KEY_LSUIElement'] = 'YES'

  # Set bundle identifier
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.wonderdrill.ScanSnapperMac'

  # Swift version
  config.build_settings['SWIFT_VERSION'] = '5.0'

  # macOS deployment target
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '12.0'

  puts "✅ Updated #{config.name} configuration"
end

project.save
puts "✅ Project settings fixed successfully!"
puts ""
puts "Next steps:"
puts "1. Clean build folder in Xcode (Cmd+Shift+K)"
puts "2. Rebuild the project"
puts "3. Run the app again"

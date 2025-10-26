#!/usr/bin/env ruby
require 'securerandom'
require 'fileutils'

PROJECT_NAME = "ScanSnapper"
PROJECT_DIR = "/Users/suguruhirayama/ScanSnapper_for_mac"
BUNDLE_ID = "com.wonderdrill.ScanSnapperMac"

# Generate UUIDs
def uuid; SecureRandom.uuid.upcase.gsub('-', '')[0..23]; end

project_uuid = uuid
app_target_uuid = uuid
sources_group_uuid = uuid
products_group_uuid = uuid
app_product_uuid = uuid
frameworks_phase_uuid = uuid
resources_phase_uuid = uuid
sources_phase_uuid = uuid
debug_config_uuid = uuid
release_config_uuid = uuid
project_config_list_uuid = uuid
target_config_list_uuid = uuid
package_ref_uuid = uuid
package_product_uuid = uuid

# File UUIDs
appdelegate_uuid = uuid
serialmanager_uuid = uuid
pasteservice_uuid = uuid
assets_uuid = uuid
infoplist_uuid = uuid

# Build file UUIDs
appdelegate_build_uuid = uuid
serialmanager_build_uuid = uuid
pasteservice_build_uuid = uuid
assets_build_uuid = uuid
package_build_uuid = uuid

pbxproj = <<PBXPROJ
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		#{appdelegate_build_uuid} /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{appdelegate_uuid} /* AppDelegate.swift */; };
		#{serialmanager_build_uuid} /* SerialManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{serialmanager_uuid} /* SerialManager.swift */; };
		#{pasteservice_build_uuid} /* PasteService.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{pasteservice_uuid} /* PasteService.swift */; };
		#{assets_build_uuid} /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = #{assets_uuid} /* Assets.xcassets */; };
		#{package_build_uuid} /* ORSSerialPort in Frameworks */ = {isa = PBXBuildFile; productRef = #{package_product_uuid} /* ORSSerialPort */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		#{app_product_uuid} /* #{PROJECT_NAME}.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = #{PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; };
		#{appdelegate_uuid} /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
		#{serialmanager_uuid} /* SerialManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SerialManager.swift; sourceTree = "<group>"; };
		#{pasteservice_uuid} /* PasteService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PasteService.swift; sourceTree = "<group>"; };
		#{assets_uuid} /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		#{infoplist_uuid} /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		#{frameworks_phase_uuid} /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				#{package_build_uuid} /* ORSSerialPort in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		#{project_uuid} = {
			isa = PBXGroup;
			children = (
				#{sources_group_uuid} /* Sources */,
				#{products_group_uuid} /* Products */,
			);
			sourceTree = "<group>";
		};
		#{sources_group_uuid} /* Sources */ = {
			isa = PBXGroup;
			children = (
				#{appdelegate_uuid} /* AppDelegate.swift */,
				#{serialmanager_uuid} /* SerialManager.swift */,
				#{pasteservice_uuid} /* PasteService.swift */,
				#{assets_uuid} /* Assets.xcassets */,
				#{infoplist_uuid} /* Info.plist */,
			);
			path = Sources;
			sourceTree = "<group>";
		};
		#{products_group_uuid} /* Products */ = {
			isa = PBXGroup;
			children = (
				#{app_product_uuid} /* #{PROJECT_NAME}.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		#{app_target_uuid} /* #{PROJECT_NAME} */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = #{target_config_list_uuid} /* Build configuration list for PBXNativeTarget "#{PROJECT_NAME}" */;
			buildPhases = (
				#{sources_phase_uuid} /* Sources */,
				#{frameworks_phase_uuid} /* Frameworks */,
				#{resources_phase_uuid} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = #{PROJECT_NAME};
			packageProductDependencies = (
				#{package_product_uuid} /* ORSSerialPort */,
			);
			productName = #{PROJECT_NAME};
			productReference = #{app_product_uuid} /* #{PROJECT_NAME}.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		#{project_uuid} /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1640;
				LastUpgradeCheck = 1640;
				TargetAttributes = {
					#{app_target_uuid} = {
						CreatedOnToolsVersion = 16.4;
					};
				};
			};
			buildConfigurationList = #{project_config_list_uuid} /* Build configuration list for PBXProject "#{PROJECT_NAME}" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = #{project_uuid};
			packageReferences = (
				#{package_ref_uuid} /* XCRemoteSwiftPackageReference "ORSSerialPort" */,
			);
			productRefGroup = #{products_group_uuid} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				#{app_target_uuid} /* #{PROJECT_NAME} */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		#{resources_phase_uuid} /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				#{assets_build_uuid} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		#{sources_phase_uuid} /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				#{appdelegate_build_uuid} /* AppDelegate.swift in Sources */,
				#{serialmanager_build_uuid} /* SerialManager.swift in Sources */,
				#{pasteservice_build_uuid} /* PasteService.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		#{debug_config_uuid} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 12.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		#{release_config_uuid} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 12.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		#{uuid} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Sources/Info.plist;
				INFOPLIST_KEY_LSUIElement = YES;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_NSPrincipalClass = NSApplication;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = #{BUNDLE_ID};
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		#{uuid} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Sources/Info.plist;
				INFOPLIST_KEY_LSUIElement = YES;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_NSPrincipalClass = NSApplication;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = #{BUNDLE_ID};
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		#{project_config_list_uuid} /* Build configuration list for PBXProject "#{PROJECT_NAME}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				#{debug_config_uuid} /* Debug */,
				#{release_config_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		#{target_config_list_uuid} /* Build configuration list for PBXNativeTarget "#{PROJECT_NAME}" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				#{uuid} /* Debug */,
				#{uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

/* Begin XCRemoteSwiftPackageReference section */
		#{package_ref_uuid} /* XCRemoteSwiftPackageReference "ORSSerialPort" */ = {
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/armadsen/ORSSerialPort.git";
			requirement = {
				kind = upToNextMajorVersion;
				minimumVersion = 2.1.0;
			};
		};
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		#{package_product_uuid} /* ORSSerialPort */ = {
			isa = XCSwiftPackageProductDependency;
			package = #{package_ref_uuid} /* XCRemoteSwiftPackageReference "ORSSerialPort" */;
			productName = ORSSerialPort;
		};
/* End XCSwiftPackageProductDependency section */
	};
	rootObject = #{project_uuid} /* Project object */;
}
PBXPROJ

# Create project structure
FileUtils.mkdir_p("#{PROJECT_DIR}/#{PROJECT_NAME}.xcodeproj")
File.write("#{PROJECT_DIR}/#{PROJECT_NAME}.xcodeproj/project.pbxproj", pbxproj)

puts "✅ Xcode project generated: #{PROJECT_NAME}.xcodeproj"
puts "📁 Location: #{PROJECT_DIR}"
puts "🚀 Next: open #{PROJECT_NAME}.xcodeproj"

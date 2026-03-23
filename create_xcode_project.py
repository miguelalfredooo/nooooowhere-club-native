#!/usr/bin/env python3
"""
Create an Xcode project structure for Nowhere native iOS app.
This script generates the .pbxproj file and project structure.
"""

import os
import json
import uuid
from pathlib import Path

PROJECT_NAME = "Nowhere"
BUNDLE_ID = "club.nowhere.app"
PROJECT_DIR = Path(__file__).parent
PROJECT_PATH = PROJECT_DIR / f"{PROJECT_NAME}.xcodeproj"
BUILD_DIR = PROJECT_DIR / "Build"
PRODUCTS_DIR = PROJECT_DIR / "Products"

def generate_uuid():
    """Generate a UUID without hyphens for Xcode project IDs."""
    return str(uuid.uuid4().hex[:24]).upper()

def create_pbxproj():
    """Create the project.pbxproj file content."""

    # Generate IDs for all objects
    project_id = generate_uuid()
    main_group_id = generate_uuid()
    sources_group_id = generate_uuid()
    resources_group_id = generate_uuid()
    supporting_group_id = generate_uuid()
    holdbutton_group_id = generate_uuid()

    target_id = generate_uuid()
    build_config_list_id = generate_uuid()
    debug_config_id = generate_uuid()
    release_config_id = generate_uuid()

    frameworks_group_id = generate_uuid()
    uikit_ref_id = generate_uuid()
    foundation_ref_id = generate_uuid()
    coreimage_ref_id = generate_uuid()
    avfoundation_ref_id = generate_uuid()

    build_phase_sources_id = generate_uuid()
    build_phase_frameworks_id = generate_uuid()
    build_phase_resources_id = generate_uuid()

    source_build_config_list_id = generate_uuid()
    source_debug_config_id = generate_uuid()
    source_release_config_id = generate_uuid()

    # File references
    files = {
        "AppDelegate": generate_uuid(),
        "SceneDelegate": generate_uuid(),
        "HoldButtonViewController": generate_uuid(),
        "HoldButtonView": generate_uuid(),
        "CanvasView": generate_uuid(),
        "Colors": generate_uuid(),
        "Info.plist": generate_uuid(),
    }

    # Build file references
    build_files = {name: generate_uuid() for name in files}

    pbxproj = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 46;
	objects = {{
/* Begin PBXBuildFile section */
"""

    # Build files
    for name in ["AppDelegate", "SceneDelegate", "HoldButtonViewController", "HoldButtonView", "CanvasView", "Colors"]:
        pbxproj += f"\t\t{build_files[name]} /* {name}.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {files[name]} /* {name}.swift */; }};\n"

    pbxproj += f"""\t\t{build_files["Info.plist"]} /* Info.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {files["Info.plist"]} /* Info.plist */; }};
\t\t{uikit_ref_id} /* UIKit.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {uikit_ref_id}_ref /* UIKit.framework */; }};
\t\t{foundation_ref_id} /* Foundation.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {foundation_ref_id}_ref /* Foundation.framework */; }};
\t\t{coreimage_ref_id} /* CoreImage.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {coreimage_ref_id}_ref /* CoreImage.framework */; }};
\t\t{avfoundation_ref_id} /* AVFoundation.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {avfoundation_ref_id}_ref /* AVFoundation.framework */; }};
/* End PBXBuildFile section */
/* Begin PBXFileReference section */
"""

    # File references
    pbxproj += f"""\t\t{files["AppDelegate"]} /* AppDelegate.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; }};
\t\t{files["SceneDelegate"]} /* SceneDelegate.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SceneDelegate.swift; sourceTree = "<group>"; }};
\t\t{files["HoldButtonViewController"]} /* HoldButtonViewController.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HoldButtonViewController.swift; sourceTree = "<group>"; }};
\t\t{files["HoldButtonView"]} /* HoldButtonView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HoldButtonView.swift; sourceTree = "<group>"; }};
\t\t{files["CanvasView"]} /* CanvasView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CanvasView.swift; sourceTree = "<group>"; }};
\t\t{files["Colors"]} /* Colors.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Colors.swift; sourceTree = "<group>"; }};
\t\t{files["Info.plist"]} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
\t\t{project_id} /* Nowhere.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Nowhere.app; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{uikit_ref_id}_ref /* UIKit.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = UIKit.framework; path = System/Library/Frameworks/UIKit.framework; sourceTree = SDKROOT; }};
\t\t{foundation_ref_id}_ref /* Foundation.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Foundation.framework; path = System/Library/Frameworks/Foundation.framework; sourceTree = SDKROOT; }};
\t\t{coreimage_ref_id}_ref /* CoreImage.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = CoreImage.framework; path = System/Library/Frameworks/CoreImage.framework; sourceTree = SDKROOT; }};
\t\t{avfoundation_ref_id}_ref /* AVFoundation.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = AVFoundation.framework; path = System/Library/Frameworks/AVFoundation.framework; sourceTree = SDKROOT; }};
/* End PBXFileReference section */
/* Begin PBXFrameworksBuildPhase section */
\t\t{build_phase_frameworks_id} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{uikit_ref_id} /* UIKit.framework in Frameworks */,
\t\t\t\t{foundation_ref_id} /* Foundation.framework in Frameworks */,
\t\t\t\t{coreimage_ref_id} /* CoreImage.framework in Frameworks */,
\t\t\t\t{avfoundation_ref_id} /* AVFoundation.framework in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */
/* Begin PBXGroup section */
\t\t{main_group_id} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{sources_group_id} /* NowNative */,
\t\t\t\t{frameworks_group_id} /* Frameworks */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{sources_group_id} /* NowNative */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{supporting_group_id} /* Supporting */,
\t\t\t\t{holdbutton_group_id} /* HoldButton */,
\t\t\t\t{resources_group_id} /* Resources */,
\t\t\t);
\t\t\tpath = NowNative;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{supporting_group_id} /* Supporting */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{files["AppDelegate"]} /* AppDelegate.swift */,
\t\t\t\t{files["SceneDelegate"]} /* SceneDelegate.swift */,
\t\t\t\t{files["Info.plist"]} /* Info.plist */,
\t\t\t);
\t\t\tpath = Supporting;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{holdbutton_group_id} /* HoldButton */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{files["HoldButtonViewController"]} /* HoldButtonViewController.swift */,
\t\t\t\t{files["HoldButtonView"]} /* HoldButtonView.swift */,
\t\t\t\t{files["CanvasView"]} /* CanvasView.swift */,
\t\t\t);
\t\t\tpath = HoldButton;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{resources_group_id} /* Resources */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{files["Colors"]} /* Colors.swift */,
\t\t\t);
\t\t\tpath = Resources;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{frameworks_group_id} /* Frameworks */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{uikit_ref_id}_ref /* UIKit.framework */,
\t\t\t\t{foundation_ref_id}_ref /* Foundation.framework */,
\t\t\t\t{coreimage_ref_id}_ref /* CoreImage.framework */,
\t\t\t\t{avfoundation_ref_id}_ref /* AVFoundation.framework */,
\t\t\t);
\t\t\tname = Frameworks;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */
/* Begin PBXNativeTarget section */
\t\t{target_id} /* Nowhere */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {source_build_config_list_id} /* Build configuration list for PBXNativeTarget "Nowhere" */;
\t\t\tbuildPhases = (
\t\t\t\t{build_phase_sources_id} /* Sources */,
\t\t\t\t{build_phase_frameworks_id} /* Frameworks */,
\t\t\t\t{build_phase_resources_id} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = Nowhere;
\t\t\tproductName = Nowhere;
\t\t\tproductReference = {project_id} /* Nowhere.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */
/* Begin PBXProject section */
\t\t{project_id} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_id} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {build_config_list_id} /* Build configuration list for PBXProject "Nowhere" */;
\t\t\tcompatibilityVersion = "Xcode 9.3";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t);
\t\t\tmainGroup = {main_group_id};
\t\t\tproductRefGroup = {main_group_id};
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_id} /* Nowhere */,
\t\t\t);
\t\t}};
/* End PBXProject section */
/* Begin PBXResourcesBuildPhase section */
\t\t{build_phase_resources_id} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{build_files["Info.plist"]} /* Info.plist in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */
/* Begin PBXSourcesBuildPhase section */
\t\t{build_phase_sources_id} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{build_files["AppDelegate"]} /* AppDelegate.swift in Sources */,
\t\t\t\t{build_files["SceneDelegate"]} /* SceneDelegate.swift in Sources */,
\t\t\t\t{build_files["HoldButtonViewController"]} /* HoldButtonViewController.swift in Sources */,
\t\t\t\t{build_files["HoldButtonView"]} /* HoldButtonView.swift in Sources */,
\t\t\t\t{build_files["CanvasView"]} /* CanvasView.swift in Sources */,
\t\t\t\t{build_files["Colors"]} /* Colors.swift in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */
/* Begin XCBuildConfiguration section */
\t\t{debug_config_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_DIALECT = "c++17";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_METHODS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_DIALECT = gnu99;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 13.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_config_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_DIALECT = "c++17";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_METHODS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_DIALECT = gnu99;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 13.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{source_debug_config_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSET_CATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSOCIATED_DOMAINS = ();
\t\t\t\tBUNDLE_IDENTIFIER = "{BUNDLE_ID}";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATED_SWIFT_HEADER_NAME = "Nowhere-Swift.h";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 13.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}";
\t\t\t\tPRODUCT_NAME = Nowhere;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t\tVERSIONING_SYSTEM = "apple-generic";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{source_release_config_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSET_CATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSOCIATED_DOMAINS = ();
\t\t\t\tBUNDLE_IDENTIFIER = "{BUNDLE_ID}";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATED_SWIFT_HEADER_NAME = "Nowhere-Swift.h";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 13.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}";
\t\t\t\tPRODUCT_NAME = Nowhere;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t\tVERSIONING_SYSTEM = "apple-generic";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */
/* Begin XCConfigurationList section */
\t\t{build_config_list_id} /* Build configuration list for PBXProject "Nowhere" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_config_id} /* Debug */,
\t\t\t\t{release_config_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{source_build_config_list_id} /* Build configuration list for PBXNativeTarget "Nowhere" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{source_debug_config_id} /* Debug */,
\t\t\t\t{source_release_config_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_id} /* Project object */;
}}
"""
    return pbxproj

def main():
    """Create the complete Xcode project structure."""

    # Create project directory
    PROJECT_PATH.mkdir(exist_ok=True)

    # Create project.pbxproj
    pbxproj_dir = PROJECT_PATH / "project.pbxproj"
    pbxproj_content = create_pbxproj()

    with open(pbxproj_dir, "w") as f:
        f.write(pbxproj_content)

    # Create .gitkeep files for empty directories
    BUILD_DIR.mkdir(exist_ok=True)
    PRODUCTS_DIR.mkdir(exist_ok=True)

    print(f"✅ Xcode project created at: {PROJECT_PATH}")
    print(f"📦 Product name: Nowhere")
    print(f"🆔 Bundle ID: {BUNDLE_ID}")
    print(f"📱 Deployment target: iOS 13.0+")
    print(f"\n🚀 Next steps:")
    print(f"1. open {PROJECT_PATH}")
    print(f"2. Build with Cmd+B")
    print(f"3. Run with Cmd+R")

if __name__ == "__main__":
    main()

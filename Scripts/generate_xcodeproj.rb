#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'xcodeproj'

project_path = 'DoFirst.xcodeproj'
FileUtils.rm_rf(project_path)

project = Xcodeproj::Project.new(project_path)
project.root_object.attributes['LastSwiftUpdateCheck'] = '2650'
project.root_object.attributes['LastUpgradeCheck'] = '2650'

def add_source_file(project, target, path)
  file_ref = project.main_group.find_file_by_path(path) || project.main_group.new_file(path)
  target.source_build_phase.add_file_reference(file_ref)
end

def add_system_framework(project, target, name)
  path = "System/Library/Frameworks/#{name}.framework"
  file_ref = project.frameworks_group.find_file_by_path(path) || project.frameworks_group.new_file(path)
  file_ref.source_tree = 'SDKROOT'
  target.frameworks_build_phase.add_file_reference(file_ref)
end

def add_resource_file(project, target, path)
  return unless File.exist?(path)

  file_ref = project.main_group.find_file_by_path(path) || project.main_group.new_file(path)
  target.resources_build_phase.add_file_reference(file_ref)
end

def configure_common(target, bundle_identifier:, info_plist:, entitlements:)
  target.build_configurations.each do |configuration|
    settings = configuration.build_settings
    settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_identifier
    settings['INFOPLIST_FILE'] = info_plist
    settings['CODE_SIGN_ENTITLEMENTS'] = entitlements
    settings['CODE_SIGN_STYLE'] = 'Automatic'
    settings['CURRENT_PROJECT_VERSION'] = '1'
    settings['DEVELOPMENT_ASSET_PATHS'] = ''
    settings['DEVELOPMENT_TEAM'] = ''
    settings['GENERATE_INFOPLIST_FILE'] = 'NO'
    settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    settings['MARKETING_VERSION'] = '1.0'
    settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
    settings['SDKROOT'] = 'auto'
    settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
    settings['SWIFT_VERSION'] = '5.0'
    settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  end
end

app_target = project.new_target(:application, 'DoFirst', :ios, '17.0')
configure_common(
  app_target,
  bundle_identifier: 'tristan.DoFirst',
  info_plist: 'DoFirst/Info.plist',
  entitlements: 'DoFirst/DoFirst.entitlements'
)
app_target.build_configurations.each do |configuration|
  configuration.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
  configuration.build_settings['SKIP_INSTALL'] = 'NO'
end

Dir.glob('DoFirst/**/*.swift').sort.each do |path|
  add_source_file(project, app_target, path)
end

add_resource_file(project, app_target, 'DoFirst/Assets.xcassets')

%w[
  DeviceActivity
  FamilyControls
  ManagedSettings
  SwiftData
  UserNotifications
].each { |framework| add_system_framework(project, app_target, framework) }

extension_targets = []

[
  {
    name: 'ShieldConfigurationExtension',
    bundle_identifier: 'tristan.DoFirst.ShieldConfigurationExtension',
    plist: 'ShieldConfigurationExtension/Info.plist',
    entitlements: 'ShieldConfigurationExtension/ShieldConfigurationExtension.entitlements',
    sources: ['ShieldConfigurationExtension/ShieldConfigurationExtension.swift'],
    frameworks: %w[ManagedSettings ManagedSettingsUI UIKit]
  },
  {
    name: 'ShieldActionExtension',
    bundle_identifier: 'tristan.DoFirst.ShieldActionExtension',
    plist: 'ShieldActionExtension/Info.plist',
    entitlements: 'ShieldActionExtension/ShieldActionExtension.entitlements',
    sources: [
      'ShieldActionExtension/ShieldActionExtension.swift',
      'DoFirst/Services/SharedScreenTimeKeys.swift'
    ],
    frameworks: %w[ManagedSettings]
  },
  {
    name: 'DeviceActivityMonitorExtension',
    bundle_identifier: 'tristan.DoFirst.DeviceActivityMonitorExtension',
    plist: 'DeviceActivityMonitorExtension/Info.plist',
    entitlements: 'DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.entitlements',
    sources: [
      'DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift',
      'DoFirst/Services/SharedScreenTimeKeys.swift'
    ],
    frameworks: %w[DeviceActivity FamilyControls ManagedSettings]
  },
  {
    name: 'DeviceActivityReportExtension',
    product_type: 'com.apple.product-type.extensionkit-extension',
    bundle_identifier: 'tristan.DoFirst.DeviceActivityReportExtension',
    plist: 'DeviceActivityReportExtension/Info.plist',
    entitlements: 'DeviceActivityReportExtension/DeviceActivityReportExtension.entitlements',
    sources: [
      'DeviceActivityReportExtension/DeviceActivityReportExtension.swift',
      'DeviceActivityReportExtension/TotalActivityReport.swift',
      'DeviceActivityReportExtension/TotalActivityView.swift'
    ],
    frameworks: %w[DeviceActivity ExtensionKit SwiftUI]
  }
].each do |definition|
  target = project.new_target(:app_extension, definition[:name], :ios, '17.0')
  target.product_type = definition[:product_type] if definition[:product_type]
  configure_common(
    target,
    bundle_identifier: definition[:bundle_identifier],
    info_plist: definition[:plist],
    entitlements: definition[:entitlements]
  )
  target.build_configurations.each do |configuration|
    configuration.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
    configuration.build_settings['SKIP_INSTALL'] = 'YES'
  end
  definition[:sources].each { |path| add_source_file(project, target, path) }
  definition[:frameworks].each { |framework| add_system_framework(project, target, framework) }
  app_target.add_dependency(target)
  extension_targets << [target, definition[:product_type]]
end

plugin_embed_phase = app_target.new_copy_files_build_phase('Embed App Extensions')
plugin_embed_phase.dst_subfolder_spec = '13'

extensionkit_embed_phase = app_target.new_copy_files_build_phase('Embed ExtensionKit Extensions')
extensionkit_embed_phase.dst_subfolder_spec = '16'
extensionkit_embed_phase.dst_path = '$(CONTENTS_FOLDER_PATH)/Extensions'

extension_targets.each do |target, product_type|
  phase = product_type == 'com.apple.product-type.extensionkit-extension' ? extensionkit_embed_phase : plugin_embed_phase
  build_file = phase.add_file_reference(target.product_reference, true)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

project.save

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app_target)
scheme.set_launch_target(app_target)
scheme.save_as(project_path, 'DoFirst', true)

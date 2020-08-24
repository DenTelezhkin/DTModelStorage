# frozen_string_literal: true
source "https://rubygems.org"

gem "fastlane"
gem 'octokit'
gem 'netrc'
gem 'jazzy'
gem 'cocoapods', '>= 1.10.0.beta.2'
gem 'mime-types'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

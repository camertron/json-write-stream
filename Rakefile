# encoding: UTF-8

require 'rubygems' unless ENV['NO_RUBYGEMS']

require 'bundler'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

require './lib/json-write-stream'

Bundler::GemHelper.install_tasks

task :default => :spec

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

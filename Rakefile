require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

load File.join(File.dirname(__FILE__),'rsql.gemspec')

Rake::GemPackageTask.new(SPEC) do |pkg|
end

task :default => :package

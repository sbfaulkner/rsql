require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  # identify the gem
  s.name = "rsql" 
  s.version = "0.9.3" 
  s.author = "S. Brent Faulkner" 
  s.email = "brentf@unwwwired.net" 
  s.homepage = "http://www.unwwwired.net" 
  # platform of choice
  s.platform = Gem::Platform::RUBY 
  # description of gem
  s.summary = "A ruby implementation of an interactive SQL command-line for ODBC" 
  candidates = Dir.glob("{bin,docs,lib,test}/**/*") 
  s.files = FileList["{bin,tests,lib,docs}/**/*"].exclude("rdoc").to_a
  s.require_path = "lib" 
  # s.autorequire = "rsql" 
  # s.test_file = "test/rsql.rb" 
  # s.has_rdoc = true 
  # s.extra_rdoc_files = ["README"] 
  # s.add_dependency("BlueCloth", ">= 0.0.4") 
end 

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

task :default => :package
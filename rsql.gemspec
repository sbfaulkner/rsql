SPEC = Gem::Specification.new do |s| 
  # identify the gem
  s.name = "rsql" 
  s.version = "1.0.5" 
  s.author = "S. Brent Faulkner" 
  s.email = "brentf@unwwwired.net" 
  s.homepage = "http://www.unwwwired.net" 
  # platform of choice
  s.platform = Gem::Platform::RUBY 
  # description of gem
  s.summary = "A ruby implementation of an interactive SQL command-line for ODBC data sources" 
  s.files = %w(bin/rsql lib/rsql/odbc.rb lib/rsql/rsql.rb MIT-LICENSE Rakefile README.markdown rsql.gemspec)
  s.require_path = "lib" 
  # s.autorequire = "rsql" 
  # s.test_file = "test/rsql.rb" 
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README.markdown"] 
  s.add_dependency("fastercsv", ">= 1.2.3") 
  s.executables = ["rsql"]
end 

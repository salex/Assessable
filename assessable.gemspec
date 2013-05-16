$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "assessable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "assessable"
  s.version     = Assessable::VERSION
  s.authors     = ["Steve Alex"]
  s.email       = ["salex@mac.com"]
  s.homepage    = "http://iwishicouldwrite.com"
  s.summary     = "assessable-#{s.version}"
  s.description = "A Rails mountable engine to provides a assessments/questions/answers structure. For use in quizzes, assessments, tests, assessments, etc."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  # s.add_dependency "jquery-rails"
  s.add_dependency "haml-rails"
  s.add_dependency "haml"
  s.add_dependency 'kaminari'
  s.add_development_dependency "sqlite3"
end

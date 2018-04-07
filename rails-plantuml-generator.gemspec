$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails/plantuml/generator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-plantuml-generator"
  s.version     = Rails::Plantuml::Generator::VERSION
  s.authors     = ["Dominic Althaus"]
  s.email       = ["althaus.dominic@gmail.com"]
  s.homepage    = "https://github.com/HappyKadaver/rails-plantuml-generator"
  s.summary     = "Generates plantuml diagrams for your Rails models."
  s.description = "Generates plantuml diagrams for your Rails models."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails"

  s.add_development_dependency "sqlite3"
end

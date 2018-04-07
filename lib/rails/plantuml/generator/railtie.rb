module Rails
  module Plantuml
    module Generator
      class Railtie < Rails::Railtie
        rake_tasks do
          load File.join(File.dirname(__FILE__),'tasks', 'plantuml.rake')
        end
      end
    end
  end
end

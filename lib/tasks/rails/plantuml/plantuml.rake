OUTPUT_FILE = 'diagramm.pu'

namespace :plantuml do
  desc "Pick a random user as the winner"
  task :generate => :environment do
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants

    models.select! &method(:class_relevant?)

    File.open OUTPUT_FILE, 'w' do |file|
      file.puts '@startuml'

      models.each do |model|
        write_class model, file
        file.puts
      end

      models.each do |model|
        write_associations model, file
        file.puts
      end
      file.puts '@enduml'
    end
  end
end

def class_relevant?(clazz)
  clazz < (ApplicationRecord || ActiveRecord::Base)
end

def class_name(clazz)
  clazz.name
end

def write_class(clazz, file)
  parent = clazz.superclass

  file.write "class #{class_name clazz} "
  file.write "extends #{class_name parent}" if class_relevant? parent
  file.puts " {"

  unless clazz.abstract_class
    columns = clazz.columns_hash.keys
    columns -= parent.columns_hash.keys if class_relevant? parent

    columns.each do |column|
      file.puts "    #{column}"
    end
  end

  file.puts "}"
end

def write_associations(clazz, file)
  associations = clazz.reflect_on_all_associations
  parent = clazz.superclass

  if class_relevant? parent
    associations.reject! do |association|
      parent.reflect_on_all_associations.any? {|parent_association| association.name == parent_association.name}
    end
  end

  associations.each do |association|
    next if association.options[:polymorphic]
    other = association.class_name

    file.write class_name(clazz)
    case
    when association.collection?
      file.write ' -- "*" '
    when association.has_one? || association.belongs_to?
      file.write ' -- "1" '
    end
    file.puts other
  end
end
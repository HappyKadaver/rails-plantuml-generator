OUTPUT_FILE = 'diagramm.pu'

ASSOCIATION_TYPE = :association_type
ASSOCIATION_OTHER_CLASS = :other_class
ASSOCIATION_TYPE_HAS_MANY = '"*"'
ASSOCIATION_TYPE_HAS_ONE = '"1"'

namespace :plantuml do
  desc "Pick a random user as the winner"
  task :generate => :environment do
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants

    models.select! &method(:class_relevant?)

    associations_hash = determine_associations models

    File.open OUTPUT_FILE, 'w' do |file|
      file.puts '@startuml'

      models.each do |model|
        write_class model, file
        file.puts
      end

      write_associations associations_hash, file
      file.puts

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

def determine_associations(models)
  result = {}

  models.each do |model|
    associations = model.reflect_on_all_associations
    parent = model.superclass

    if class_relevant? parent
      associations.reject! do |association|
        parent.reflect_on_all_associations.any? {|parent_association| association.name == parent_association.name}
      end
    end

    result[model] = []

    associations.each do |association|
      next if association.options[:polymorphic]
      other = association.class_name.constantize

      case
      when association.collection?
        result[model].append({
                                 ASSOCIATION_TYPE => ASSOCIATION_TYPE_HAS_MANY,
                                 ASSOCIATION_OTHER_CLASS => other
                             })
      when association.has_one? || association.belongs_to?
        result[model].append({
                                 ASSOCIATION_TYPE => ASSOCIATION_TYPE_HAS_ONE,
                                 ASSOCIATION_OTHER_CLASS => other
                             })
      end
    end
  end

  result
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

def write_associations(association_hash, file)
  association_hash.each do |clazz, associations|
    associations.each do |meta|
      other = meta[ASSOCIATION_OTHER_CLASS]
      back_associtiation_meta = association_hash[other].find {|other_meta| other_meta[ASSOCIATION_OTHER_CLASS] == clazz}
      back_associtiation_symbol = back_associtiation_meta[ASSOCIATION_TYPE] if back_associtiation_meta
      association_hash[other].delete back_associtiation_meta

      file.puts "#{class_name clazz} #{back_associtiation_symbol} -- #{meta[ASSOCIATION_TYPE]} #{class_name other}"
    end
  end
end
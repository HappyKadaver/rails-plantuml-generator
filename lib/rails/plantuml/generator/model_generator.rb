module Rails
  module Plantuml
    module Generator
      class ModelGenerator
        def initialize(models, whitelist_regex)
          @whitelist_regex = Regexp.new whitelist_regex if whitelist_regex
          @models = models.select { |m| class_relevant? m }

          @associations_hash = determine_associations @models
        end

        def class_relevant?(clazz)
          return false unless clazz < ((defined? ApplicationRecord).present? ? ApplicationRecord : ActiveRecord::Base)
          return true unless @whitelist_regex
          !@whitelist_regex.match(clazz.name).nil?
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
              next if association.through_reflection
              other = association.klass

              next unless class_relevant? other

              case
              when association.collection?
                result[model].append({
                                         ASSOCIATION_TYPE => ASSOCIATION_TYPE_HAS_MANY,
                                         ASSOCIATION_OTHER_CLASS => other,
                                         ASSOCIATION_OTHER_NAME => association.name
                                     })
              when association.has_one? || association.belongs_to?
                result[model].append({
                                         ASSOCIATION_TYPE => ASSOCIATION_TYPE_HAS_ONE,
                                         ASSOCIATION_OTHER_CLASS => other,
                                         ASSOCIATION_OTHER_NAME => association.name
                                     })
              end
            end
          end

          result
        end

        def write_to_io(io)
          io.puts '@startuml'

          @models.each do |model|
            write_class model, io
            io.puts
          end

          write_associations @associations_hash, io
          io.puts

          io.puts '@enduml'
        end

        def write_class(clazz, io)
          parent = clazz.superclass

          io.write "class #{class_name clazz} "
          io.write "extends #{class_name parent}" if class_relevant? parent
          io.puts " {"

          unless clazz.abstract_class
            columns = clazz.columns_hash.keys
            columns -= parent.columns_hash.keys if class_relevant? parent

            columns.each do |column|
              io.puts "    #{column}"
            end
          end

          io.puts "}"
        end

        def write_associations(association_hash, io)
          association_hash.each do |clazz, associations|
            associations.each do |meta|
              other = meta[ASSOCIATION_OTHER_CLASS]
              back_associtiation_meta = association_hash[other]&.find {|other_meta| other_meta[ASSOCIATION_OTHER_CLASS] == clazz}

              back_associtiation_symbol = back_associtiation_meta[ASSOCIATION_TYPE] if back_associtiation_meta
              back_associtiation_name = back_associtiation_meta[ASSOCIATION_OTHER_NAME] if back_associtiation_meta

              association_hash[other]&.delete back_associtiation_meta
              associations.delete meta

              io.write class_name clazz

              io.write " \"#{back_associtiation_symbol}\"" if back_associtiation_meta

              io.write " -- \"#{meta[ASSOCIATION_TYPE]}\" #{class_name other} : \"#{meta[ASSOCIATION_OTHER_NAME]}"
              io.write "\\n#{back_associtiation_name}" if back_associtiation_meta
              io.puts '"'
            end
          end
        end
      end
    end
  end
end

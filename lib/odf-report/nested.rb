module ODFReport

  module Nested

    def replace_fields!(new_section, data_item)
      field_replace!(new_section, data_item)
    end

    def get_collection_from_item(item, collection_field)

      return item[collection_field] if item.is_a?(Hash)

      if collection_field.is_a?(Array)
        tmp = item.dup
        collection_field.each do |f|
          if f.is_a?(Hash)
            tmp = tmp.send(f.keys[0], f.values[0])
          else
            tmp = tmp.send(f)
          end
        end
        collection = tmp
      elsif collection_field.is_a?(Hash)
        collection = item.send(collection_field.keys[0], collection_field.values[0])
      else
        collection = item.send(collection_field)
      end

      return collection
    end

  end

end
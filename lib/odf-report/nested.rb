module ODFReport

  module Nested

    def replace_values!(new_section, data_item)
      node_hash_gsub!(new_section, get_fields_with_values(data_item))
    end

    def get_fields_with_values(data_item)

      fields_with_values = {}
      row_has_non_empty_cell = false
      @fields.each do |field_name, block1|
        cell = block1.call(data_item) || ''
        fields_with_values[field_name] = cell
        row_has_non_empty_cell = true if cell.present?
      end
      
      if @skip_empty_rows && !row_has_non_empty_cell
        # If all cells (fields) in the row are empty (empty string) and
        # the :skip_empty_rows option is true, then reset the row to the
        # empty hash. This effectively skips that empty row...
        fields_with_values = {}
      end

      fields_with_values
    end

    def get_collection_from_item(item, collection_field)

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
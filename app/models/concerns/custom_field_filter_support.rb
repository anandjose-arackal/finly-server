module CustomFieldFilterSupport
  extend ActiveSupport::Concern

  included do
    scope :filter_custom_text_selection, -> (filtered_text_obj){
      if filtered_text_obj.present?
        custom_field_filtered_documents = self
        parent_table_name = self.first&.class&.table_name
        if parent_table_name.present?
          filtered_text_obj.each.with_index(1) do |raw_hash, index|
            parsed_hash = JSON.parse(raw_hash).with_indifferent_access
            id = parsed_hash[:id]
            value = parsed_hash[:value]
            if id.present? && value.present?
              custom_field_filtered_documents = custom_field_filtered_documents.joins("INNER JOIN custom_fields AS tcf#{index} ON tcf#{index}.parent_id = #{parent_table_name}.id INNER JOIN field_texts AS ft#{index} ON ft#{index}.id = tcf#{index}.value_id").where("tcf#{index}.field_configuration_id = ?", id).where("ft#{index}.value LIKE ?", "%#{value}%")
            end
          end
        end
        custom_field_filtered_documents
      end
    }

    scope :filter_custom_drop_down_selection, -> (filter_dropdown_obj){
      if filter_dropdown_obj.present?
        custom_field_filtered_documents = self
        parent_table_name = self.first&.class&.table_name
        if parent_table_name.present?
          filter_dropdown_obj.each.with_index(1) do |raw_hash, index|
            parsed_hash = JSON.parse(raw_hash).with_indifferent_access
            id = parsed_hash[:id]
            value_id = parsed_hash[:value]
            if id.present? && value_id.present?
              custom_field_filtered_documents = custom_field_filtered_documents.joins("INNER JOIN custom_fields AS dcf#{index} ON dcf#{index}.parent_id = #{parent_table_name}.id INNER JOIN field_drop_down_selections AS fds#{index} ON fds#{index}.id = dcf#{index}.value_id").where("dcf#{index}.field_configuration_id = ?", id).where("fds#{index}.value_id = ?", value_id)   
            end
          end
        end
        custom_field_filtered_documents
      end
    }    
  end
end
class Forms::Contracts::Builders::CustomField

  def self.call(reform, form_custom_fields)
    reform.collection :form_custom_fields, deserializer: Forms::Contracts::Builders::CustomField::Build(form_custom_fields) do
      property :uuid
      property :form_entity_id
      property :field_key
      property :entity_type
      property :value
      property :value_text
      # collection :attachments, populator: :attachments! do
      #   property :uuid
      # end
      #
      # def attachments!
      #   attachment = attachments.find {|attachment| attachment.id.to_s == fragment["id"].to_s}
      #
      #   if fragment["_destroy"]
      #     attachments.destroy(attachment)
      #     return skip!
      #   end
      #
      #   attachment || attachments.append(CustomFieldAttachment.find_by uuid: fragment[:id])
      # end
    end
  end

  def self.Build(form_custom_fields)
    -> (input, represented, **) do
      # represented.custom_fields = represented.model.present? ? represented.model.custom_fields : []
      represented.form_custom_fields = []
      form_custom_fields.each do |custom_field_entity|
        custom_field = represented.form_custom_fields.find_by(form_entity_id: custom_field_entity.uuid)
        if custom_field.nil?
          custom_field = build_custom_field custom_field_entity
        end

        collection_custom_fields = []
        if custom_field_entity.parent.present? && custom_field_entity.parent.class.collection?
          input[custom_field_entity.parent.entity_key].each_with_index do |line_item, index|
            if line_item['collection_uuid'] == ""
              input[custom_field_entity.parent.entity_key][index]['collection_uuid'] = SecureRandom.uuid
            end
            collection_custom_fields << build_custom_field(custom_field_entity, input[custom_field_entity.parent.entity_key][index]['collection_uuid'])
          end
        end

        # Method 2
        case custom_field_entity.entity_type
        when 'dropdown'
          if custom_field_entity.parent.present? && custom_field_entity.parent.class.collection?
            collection_custom_fields.each do |cf|
              cf.value = nil
              if cf.selection.present?
                cf.selection.assign_attributes(form_entity_choice_id: input[custom_field_entity.parent.entity_key].select{|item| item['collection_uuid'] == cf.collection_uuid}.first[custom_field_entity.entity_key])
              else
                cf.selection = CustomFieldSelection.new(form_entity_choice_id: input[custom_field_entity.parent.entity_key].select{|item| item['collection_uuid'] == cf.collection_uuid}.first[custom_field_entity.entity_key])
              end
            end
          else
            custom_field.value = nil
            if custom_field.selection.present?
              custom_field.selection.assign_attributes(form_entity_choice_id: input[custom_field_entity.entity_key])
            else
              custom_field.selection = CustomFieldSelection.new(form_entity_choice_id: input[custom_field_entity.entity_key]) if input[custom_field_entity.entity_key].present?
            end
          end

        when 'attachment'
          custom_field.value = ""
          input[custom_field_entity.entity_key].present? && input[custom_field_entity.entity_key].is_a?(Array) && input[custom_field_entity.entity_key].each do |attachment_obj|
            attachment = CustomFieldAttachment.find_by uuid: attachment_obj[:id]

            # Rails.logger.error("********************** #{custom_field_entity.entity_key} - #{attachment_obj[:name]}**********************")

            if attachment.present?
              if attachment_obj[:_destroy]
                attachment.destroy
              else
                attachment.update(form_custom_field_id: custom_field&.uuid)
                custom_field.attachments << attachment
              end
              # debugger
              # custom_field.attachments.find_by(id: attachment_obj[:id])&.mark_for_destruction if attachment_obj[:_destroy].present?
              # custom_field.attachments.new(attachment: attachment_obj[:attachment]) unless attachment_obj[:id].present?
            end
          end
          # when 'attachment'
          #   # debugger
          #   custom_field.value = ""
          #   # input[custom_field_entity.entity_key].present? && input[custom_field_entity.entity_key].is_a?(Array) && input[custom_field_entity.entity_key].each do |attachment_obj|
          #   #   attachment = CustomFieldAttachment.find_by uuid: attachment_obj[:id]
          #   #
          #   #   # debugger
          #   #
          #   #   if attachment.present?
          #   #     custom_field&.model&.attachments << attachment
          #   #     # debugger
          #   #     attachment.mark_for_destruction if attachment_obj[:_destroy].present?
          #   #     # custom_field.attachments.find_by(id: attachment_obj[:id])&.mark_for_destruction if attachment_obj[:_destroy].present?
          #   #     # custom_field.attachments.new(attachment: attachment_obj[:attachment]) unless attachment_obj[:id].present?
          #   #   end
          #   # end

        when 'multiselect'
          # Implement later - #todo
        else
          if custom_field_entity.parent.present? && custom_field_entity.parent.class.collection?
            collection_custom_fields.each do |cf|
              cf.value = input[custom_field_entity.parent.entity_key].select{ |item| item['collection_uuid'] == cf.collection_uuid}.first[custom_field_entity.entity_key] rescue nil
            end
          else
            custom_field.value = input[custom_field_entity.entity_key]
          end
        end
        if custom_field_entity.parent.present? && custom_field_entity.parent.class.collection?
          collection_custom_fields.each do |cf|
            represented.form_custom_fields.append(cf)
          end
        else
          represented.form_custom_fields.append(custom_field)
        end
      end
    end
  end

  def self.build_custom_field(custom_field_entity, collection_uuid = nil)
    FormCustomField.new(
      {
        form_entity: custom_field_entity,
        form_id: custom_field_entity.form_id,
        field_key: custom_field_entity.entity_key,
        entity_type: custom_field_entity.entity_type,
        collection_uuid: collection_uuid
      }
    )
  end
end

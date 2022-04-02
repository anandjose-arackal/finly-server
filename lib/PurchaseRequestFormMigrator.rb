class PurchaseRequestFormMigrator
  def self.perform(company_id)

    result = []
    company = Company.find company_id
    
    ActsAsTenant.with_tenant(company) do
      documents = PurchaseRequest.where(company_id: company.id)
      # documents = PurchaseRequest.where(company_id: company.id, id: 90)

      form = Form.where(klass_name: 'Docs::P2P::PurchaseRequests::Form', company_id: company_id).first
      documents.find_in_batches(batch_size: 1000) do |batch|
        batch.each do |document|

          # Populate Custom Fields

          form.entities.root.custom_fields.each do |entity|
            form_custom_field = FormCustomField.where(field_key: entity.entity_key, document_type: document.class.name, document_id: document.id).order(created_at: :asc).last
            if form_custom_field.present?
              form_custom_field.update(form_entity_id: entity.id, entity_type: entity.entity_type, form_id: form.id)
            else
              FormCustomField.new({
                form_entity_id: entity.id, field_key: entity.entity_key,
                entity_type: entity.entity_type, document_type: document.class.name,
                document_id: document.id, form_id: form.id}
                ).save
            end
          end

          # Migrate Custom Fields
          update_custome_fields form, document, company
          
          # First migrate pr line items
          update_item document

          # Migrate pr Data
          update_pr_details document
          
          # Migrate Attachments
          update_pr_attachments( form, document)

        end
      end
    end
    # Todo - I2P:
    # Log and output file for future reference; Will be useful in case data is not migrated properly
  end

  def self.update_custome_fields form, document, company
    document.custom_fields.each do |custom_field|
      field_name = custom_field.field_configuration.field_name.split(" ").join("_").underscore

      form_custom_field = document.form_custom_fields.where(field_key: field_name).order(updated_at: :asc).last

      if form_custom_field.present?
        update_each_custom_field( form_custom_field, custom_field)
      else

        entity_key = custom_field.field_configuration.field_name.split(" ").join("_").underscore

        form_entity = form.entities.where(entity_key: entity_key).first
        if form_entity.blank?
          if custom_field.value_type == 'FieldText'
            form_entity = create_text_custom_field(form, custom_field, company)
          elsif custom_field.value_type == 'FieldDropDownSelection'
            form_entity = create_drop_down_custom_field(form, custom_field, company)
          end
        end
        
        next if form_entity == nil
        form_custom_field = FormCustomField.create({
          form_entity_id: form_entity.id, field_key: form_entity.entity_key,
          entity_type: form_entity.entity_type, document_type: document.class.name,
          document_id: document.id, form_id: form.id }
        )

        update_each_custom_field( form_custom_field, custom_field)
      end
    end
  end

  def self.create_text_custom_field form, custom_field, company
    form_id = form.uuid
    section_id = FormSection.where(section_id: 'request_details', company_id: company.id, form_id: form_id).first.uuid
    required = custom_field.field_configuration.mandatory
    active = custom_field.field_configuration.enabled
    lable = custom_field.field_configuration.field_name
    entity_key = custom_field.field_configuration.field_name.split(" ").join("_").underscore
    position = form.entities.where(form_section_id: section_id).order(:position).last.position + 1
    # is_active = !custom_field.field_configuration.deleted?

    field_max_data_length = custom_field.field_configuration.custom_fields.map(&:value).compact.map(&:value).compact.map(&:length).max
    if field_max_data_length <= 30
      form_entity = FormEntity::Text.create({ company_id: company.id,
        form_id: form_id, form_section_id: section_id,
        created_by_user_id: company.users.only_admins.first,
        entity_key: entity_key, label: lable,
        placeholder: 'Enter value', hint: 'Please enter the hint',
        entity_type: 'text', editable: true, required: required,
        active: active, unique: false, visible: true, position: position,
        system_field: false, options: "{'format':'text','minimum':1,'maximum':255}"
        # , active: is_active
      })
    else
      form_entity = FormEntity::LargeText.create({ company_id: company.id,
        form_id: form_id, form_section_id: section_id,
        created_by_user_id: company.users.only_admins.first,
        entity_key: entity_key, label: lable,
        placeholder: 'Enter value', hint: 'Please enter the hint',
        entity_type: 'large_text', editable: true, required: required,
        active: active, unique: false, visible: true, position: position,
        system_field: false,
        options: "{ 'maximum': 65535, 'minimum': 0 }"
      })
    end

    form_entity
  end

  def self.create_drop_down_custom_field form, custom_field, company

    form_id = form.uuid
    section_id = FormSection.where(section_id: 'request_details', company_id: company.id, form_id: form_id).first.uuid
    required = custom_field.field_configuration.mandatory
    active = custom_field.field_configuration.enabled
    lable = custom_field.field_configuration.field_name
    entity_key = custom_field.field_configuration.field_name.split(" ").join("_").underscore
    position = form.entities.where(form_section_id: section_id).order(:position).last.position + 1
    # is_active = !custom_field.field_configuration.deleted?

    # create entity
    form_entity = FormEntity::DropDown.create({ company_id: company.id,
     form_id: form_id, form_section_id: section_id,
     created_by_user_id: company.users.only_admins.first.id,
     entity_key: entity_key, label: lable,
     placeholder: 'Enter value', hint: 'Please enter the hint',
     entity_type: 'dropdown', editable: true, required: required,
     active: active, unique: false, visible: true, position: position,
     system_field: false, choices_scope: nil,
     options: {}
     # ,active: is_active
    })

    choices = Choices['list'].()
    choices.form_entity = form_entity
    form_entity.update(choices_scope: choices )
    
    # create options
    custom_field.field_configuration.drop_down_items.each do |item|

      form_entity.choices.create({
        company_id: company.id,
        form_id: form_id,
        form_section_id: section_id,        
        created_by_user_id: company.users.only_admins.first.id,
        name: item.name,
        position: 1, 
        active: true
      })
    end

    form_entity
  end


  def self.update_each_custom_field form_custom_field, custom_field
      
    if ["text", "large_text" ].include? form_custom_field&.form_entity&.entity_type 
      form_custom_field.value = custom_field.value&.value
      form_custom_field.save

    elsif form_custom_field&.form_entity&.entity_type == "dropdown"
      custom_field_value = custom_field.value&.value&.name
      selection = form_custom_field&.form_entity&.choices&.where(name: custom_field_value).first
      # A selection with the same name as of custom field selection is found
      if selection.present?
        if form_custom_field&.selection.present?
          # If form custom field selection is already there, then update it
          form_custom_field.selection.update(form_entity_choice_id: selection.uuid)
        else
          # If form custom field doesn't have a selection then create a new selection
          CustomFieldSelection.create(form_entity_choice_id: selection.uuid, form_custom_field_id: form_custom_field.uuid)
        end
      end
    end
  end


  def self.update_item document
    document.items.each do |pr_item| 
      rate = pr_item&.per_unit_estimated_amount.value.to_f
      update_params = {
      
        item_description: pr_item&.item&.description,
        item_number: pr_item&.item&.item_number,
        items_department_id: pr_item&.department_id,
        items_cost_center_id: pr_item&.cost_center_id,
        item_rate: rate,
        rate: rate,
        item_gross_amount: pr_item.estimated_amount&.value&.to_f, 
        reporting_item_gross_amount: pr_item.estimated_amount&.value&.to_f
      }
      pr_item.skip_callback = true
      pr_item.update_columns(update_params)
    end
  end

  def self.update_pr_details document
    update_params = {

      # creator_name:  document&.creator&.name,
      # creator_email:  document&.creator&.email,
      conversion_date: document.created_at.to_date,
      base_currency_id: Currency.find_by(country_code: 'INR').id,
      reporting_currency_id: Currency.find_by(country_code: 'INR').id,
      conversion_rate: 1,
      pr_gross_amount:  document&.total_amount&.value.to_f,
      reporting_pr_gross_amount:  document&.total_amount&.value.to_f,
    }
    document.skip_callback = true
    document.update_columns(update_params)
  end

  def self.update_pr_attachments( form, document)
    document.attachments.each do |old_attachment|
      relevant_custom_field = document.form_custom_fields.where(field_key: 'purchase_request_attachments').first

      if relevant_custom_field.present?
        new_attachment = add_attachment_to_new_pr( old_attachment, relevant_custom_field )
      else
        entity  = form.entities.where(entity_key: 'purchase_request_attachments').first
        document.form_custom_fields.create({
            document_type: 'PurchaseRequest', document_id: document.id, form_id: form.id, form_entity_id: entity.id,
            field_key: 'purchase_request_attachments', value: "", value_text: nil, entity_type: 'attachments',
         })

        relevant_custom_field = document.form_custom_fields.where(field_key: 'purchase_request_attachments').first
        new_attachment = add_attachment_to_new_pr( old_attachment, relevant_custom_field )
      end
      
      new_attachment.update_attribute(:attachment_updated_at,  old_attachment.created_at )
    end    
  end

  def self.add_attachment_to_new_pr( old_attachment, relevant_custom_field )
    new_attachment = relevant_custom_field.attachments.new()
    if Rails.env.production?
      begin
        new_attachment.attachment = old_attachment.file
        new_attachment.save
      rescue Paperclip::AdapterRegistry::NoHandlerError => e
        attachment_error = "Company #{company.id} \n Document Type: #{document.class.name} \n Document ID: #{document.id} \n Attachment ID : #{old_attachment.id} \n Attachment Type: #{old_attachment.attachment_type} \n\n"
        puts attachment_error
        result.push(attachment_error)
      end
    else
      file_path = Rails.root.to_s + "/public" + old_attachment.file.url(:original, false)
      file = File.open(file_path) rescue nil

      if file.present?
        new_attachment.attachment = old_attachment.file
        new_attachment.save
      end
    end
    new_attachment
  end
end
class PoInvoiceFormMigrator
  def self.perform(company_id)

    result = []
    company = Company.find company_id
    
    ActsAsTenant.with_tenant(company) do
      documents = Invoice.where(invoice_type_id: InwardInvoiceType.id_for(:tax_invoice)).where(company_id: company.id)
      # documents = Invoice.where(id: 10834)

      # FormCustomField.where(company_id: company_id).destroy_all
      form = Form.where(klass_name: 'Docs::P2P::Invoices::NonPo::Form', company_id: company_id).first
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
          
          # First migrate invoice line items
          update_item document

          # Migrate Invoice Data
          update_invoice_details document
          
          # Migrate Attachments
          update_invoice_attachments( form, document)

        end
      end
    end
    # Todo - I2P:
    # Log and output file for future reference; Will be useful in case data is not migrated properly
  end

  def self.update_custome_fields form, document, company
    document.custom_fields.each do |custom_field|
      # field_name = custom_field.field_configuration.field_name

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
    section_id = FormSection.where(section_id: 'invoice_details', company_id: company.id, form_id: form_id).first.uuid
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
    section_id = FormSection.where(section_id: 'invoice_details', company_id: company.id, form_id: form_id).first.uuid
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
    choices.entity = form_entity
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
    #MAPPING
    document.items.each do |item| 
      item_tds = 0
      if item&.tds_applicable
        item_tds = ( item&.taxable_amount&.value.to_f * document&.tds_slab&.tds.to_f ) / 100
        item_tds = item_tds.to_f.round(2)
      end
      
      item_taxable_amount = item.goods? ? item&.taxable_amount&.value&.to_f : item&.billable_amount&.value&.to_f
      item_tax_amount = item&.tax_amount&.value&.to_f
      
      # item net amount = item_taxable_amount + tax
      item_net_amount = item_taxable_amount.to_f + item_tax_amount.to_f


      update_params = {

        # quantity: item.quantity,
        # inventory_line_item_id: item.inventory_line_item_id,
        # category_id: item&.category_id,
        # tds_applicable: item&.tds_applicable,
        # description: item.description,
        # comment: ,
        
        
        # hsn_sac: item.hsn_sac,
        # unit_of_measurement: item.unit_of_measurement,
        # rate: item.rate,
        # discount: item.discount,
        # tax_rate_id: item.tax_rate_id,
        tax_percentage: item&.tax_rate&.rate,
        
        gl_code: item&.gl_code.present? ? item&.gl_code :  ( item&.category&.gl_code.present? ? item&.category&.gl_code : item&.inventory_line_item&.item_number),
        item_number: item&.inventory_line_item&.item_number,
        unbilled_quantity: item.quantity,
        items_department_id: item&.department_id,
        items_cost_center_id: item&.cost_center_id,
        product_type_id: item&.inventory_line_item&.product_type_id,
        item_rate: item&.rate.to_f,
        rate: item&.rate.to_f,
        item_gross_amount: item&.amount&.value.to_f,
        reporting_item_gross_amount: item&.amount&.value.to_f,

        item_discount_amount: item&.discount_amount&.value.to_f,
        reporting_item_discount_amount: item&.discount_amount&.value.to_f,
        
        item_billable_amount: item&.billable_amount&.value.to_f,
        reporting_item_billable_amount: item&.billable_amount&.value.to_f,

        item_taxable_amount: item_taxable_amount,
        reporting_item_taxable_amount: item_taxable_amount,

        item_tax_amount: item_tax_amount,
        reporting_item_tax_amount: item_tax_amount,
        
        item_tds_amount: item_tds,
        reporting_item_tds_amount: item_tds,
        
        # item net amount = item_gross_amount - discount + tax
        item_net_amount: item_net_amount,
        reporting_item_net_amount: item_net_amount

      }
      item.skip_callback = true
      item.update_columns(update_params)
    end
  end

  def self.update_invoice_details document
    

    invoice_sub_total_amount = document&.item_amounts_total.to_f - document&.discount_amount&.value.to_f + document&.tax_amount&.value.to_f + document&.freight_amount&.value.to_f
    if document&.rcm_enabled
      invoice_sub_total_amount = invoice_sub_total_amount.to_f - document&.tax_amount&.value.to_f
    end
    invoice_total_amount = invoice_sub_total_amount + document&.roundoff_amount.to_f - document&.tds_amount&.value.to_f - document&.advance_amount&.value.to_f 

    update_params = {

      base_currency_id: Currency.find_by(country_code: 'INR').id,
      reporting_currency_id: Currency.find_by(country_code: 'INR').id,
      conversion_rate: 1,
      retrieve_conversion_rate: true,

      # invoice_status_id: document&.invoice_status_id,
      # invoice_id: document&.invoice_id,
      # invoice_number: document&.invoice_number,
      # date: document&.date,
      # payment_term_id: document&.payment_term_id ,
      # due_date: document&.due_date,
      # cost_allocation_items: document&.cost_allocation_items,
      # transaction_service_period_from: document&.transaction_service_period_from,
      # transaction_service_period_to: document&.transaction_service_period_to ,
      # policy_id: document&.policy_id,
      # department_id: document&.department_id,
      # cost_center_id: document&.cost_center_id,
      # discount_type_id: document&.discount_type_id,
      # narration: document&.narration,
      # vendor_id: document&.invoice_id,

      payment_term_days: document&.payment_term&.days_after,
      tax_type_id: document&.gst_type_id,
      conversion_date: document&.date&.to_date,

      # VENDOR DETAILS
      vendor_country_id: Country.id_for(document&.vendor&.vendor_country),
      vendor_trade_name:  document&.vendor&.trade_name || document&.vendor&.business_name,
      vendor_sequence_id: document&.vendor&.vendor_id,
      vendor_gstin: document&.gstin_location&.gstin,
      vendor_pan: document&.vendor&.pan,
      
      gstin_location_id: document&.gstin_location_id,
      vendor_bank_account_number: document&.receiving_account&.account_number,
      vendor_bank_account_ifsc: document&.receiving_account&.ifsc,
      vendor_bank_account_swift_code: document&.receiving_account&.swift_code,

      billing_address_name: document&.location&.name,
      billing_address_gstin: document&.location&.gstin,

      shipping_address_name: document&.delivery_location&.name,
      shipping_address_gstin: document&.delivery_location&.gstin,

      # receiving_account_id: document&.receiving_account_id,
      # receiving_account_type: document&.receiving_account_type,
      # rcm_enabled: document&.rcm_enabled,
      # location_id: document&.location_id,
      # delivery_location_id: document&.delivery_location_id,
      # billing_address: document&.billing_address,
      # shipping_address: document&.shipping_address,

      # INVOICE SUMMARY
      invoice_gross_amount: document&.item_amounts_total.to_f,
      reporting_invoice_gross_amount: document&.item_amounts_total.to_f,

      invoice_discount_amount: document&.discount_amount&.value,
      reporting_invoice_discount_amount: document&.discount_amount&.value,
      
      invoice_taxable_amount: document.gross_amount&.value.to_f,
      reporting_invoice_taxable_amount: document.gross_amount&.value.to_f,

      # total_line_item_discount_amount: document&.discount_amount&.value,
      # overall_discount_amount: 0,
      
      invoice_tax_amount: document&.tax_amount&.value,
      reporting_invoice_tax_amount: document&.tax_amount&.value,

      tds_percentage: document&.tds_slab&.tds,
      invoice_tds_amount: document&.tds_amount&.value,
      reporting_invoice_tds_amount: document&.tds_amount&.value,
      
      invoice_freight_amount: document&.freight_amount&.value,
      reporting_invoice_freight_amount: document&.freight_amount&.value,
      
      invoice_paid_outside_amount: document&.advance_amount&.value.to_f,
      reporting_invoice_paid_outside_amount: document&.advance_amount&.value.to_f,

      invoice_roundoff_amount: document&.roundoff_amount,
      reporting_invoice_roundoff_amount: document&.roundoff_amount,

      invoice_sub_total_amount: invoice_sub_total_amount,
      reporting_invoice_sub_total_amount: invoice_sub_total_amount,
      
      invoice_total_amount: invoice_total_amount.to_f,
      reporting_invoice_total_amount: invoice_total_amount.to_f,

      invoice_net_total_amount: invoice_total_amount.to_f,
      reporting_invoice_net_total_amount: invoice_total_amount.to_f,
            
      invoice_advance_paid_amount: document&.payments&.successful&.joins(:amount)&.sum(:value),
      reporting_invoice_advance_paid_amount: document&.payments&.successful&.joins(:amount)&.sum(:value),

      invoice_balance_due: document&.balance_due&.value.to_f,
      reporting_invoice_balance_due: document&.balance_due&.value.to_f
    }
    document.skip_callback = true
    document.update_columns(update_params)
  end

  def self.update_invoice_attachments( form, document)
    document.attachments.each do |old_attachment|
      relevant_custom_field = document.form_custom_fields.where(field_key: 'invoice_attachments').first

      if relevant_custom_field.present?
        new_attachment = add_attachment_to_new_invoice( old_attachment, relevant_custom_field )
      else
        entity  = form.entities.where(entity_key: 'invoice_attachments').first
        document.form_custom_fields.create({
            document_type: 'Invoice', document_id: document.id, form_id: form.id, form_entity_id: entity.id,
            field_key: 'invoice_attachments', value: "", value_text: nil, entity_type: 'attachments',
         })

        relevant_custom_field = document.form_custom_fields.where(field_key: 'invoice_attachments').first
        new_attachment = add_attachment_to_new_invoice( old_attachment, relevant_custom_field )
      end
      
      new_attachment.update_attribute(:attachment_updated_at,  old_attachment.created_at )
    end    
  end

  def self.add_attachment_to_new_invoice( old_attachment, relevant_custom_field )
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
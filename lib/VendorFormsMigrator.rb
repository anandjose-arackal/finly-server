# Forms::Synchronizer.(master: 'Masters::Vendors::Form', company_id: 214)
# RAILS_ENV=production nohup rails runner 'VendorFormsMigrator.run' --trace > vendor_forms_migration_[company_id].log 2>&1 &
# RAILS_ENV=production nohup rails runner 'VendorFormsMigrator.perform' --trace > ~/vendor_forms_migration_2.log 2>&1 &
# RAILS_ENV=production nohup rails runner 'VendorFormsMigrator.perform(248)' --trace > ~/vendor_forms_migration_248.log 2>&1 &


# Checklist:
# [] Change Company ID Below & Deploy
# [] Vendor Form is seeded for the company
# [] Custom Fields are added for Vendor

class VendorFormsMigrator
  def self.perform(company_id)

    result = []

    company = Company.find company_id
    documents = YesBankVendor.where(company_id: company.id).authorized
    form = Form.where(klass_name: 'Masters::Vendors::Form', company_id: company_id).first

    documents.find_in_batches(batch_size: 1000) do |batch|
      batch.each do |document|
        # Create custom fields
        form.entities.root.custom_fields.each do |entity|
          form_custom_field = FormCustomField.where(field_key: entity.entity_key, document_type: document.class.name, document_id: document.id).order(created_at: :asc).last
          if form_custom_field.present?
            form_custom_field.update(form_entity_id: entity.id, entity_type: entity.entity_type, form_id: form.id)
          else
            FormCustomField.new({form_entity_id: entity.id, field_key: entity.entity_key, entity_type: entity.entity_type, document_type: document.class.name, document_id: document.id, form_id: form.id}).save
          end
        end

        # Create custom fields for
        document.bank_accounts.each do |bank_account|
          form.entities.where(entity_key: :bank_accounts).first.entities.custom_fields.each do |entity|
            form_custom_field = FormCustomField.where(field_key: entity.entity_key, document_type: bank_account.class.name, document_id: bank_account.id).order(created_at: :asc).last
            if form_custom_field.present?
              form_custom_field.update(value: bank_account.account_number, form_entity_id: entity.id, entity_type: entity.entity_type, form_id: form.id)
            else
              if entity.entity_key == 'confirm_account_number'
                FormCustomField.new({
                                        form_entity_id: entity.id,
                                        field_key: entity.entity_key,
                                        entity_type: entity.entity_type,
                                        document_type: bank_account.class.name,
                                        document_id: bank_account.id,
                                        form_id: form.id,
                                        value: bank_account.account_number
                                    }).save
              else
                FormCustomField.new({
                                        form_entity_id: entity.id,
                                        field_key: entity.entity_key,
                                        entity_type: entity.entity_type,
                                        document_type: bank_account.class.name,
                                        document_id: bank_account.id,
                                        form_id: form.id
                                    }).save
              end
            end
          end
        end

        # Create for GSTIN Locations
        document.gstin_locations.each do |gstin_location|
          form.entities.where(entity_key: :gstin_locations).first.entities.custom_fields.each do |entity|
            form_custom_field = FormCustomField.where(field_key: entity.entity_key, document_type: gstin_location.class.name, document_id: gstin_location.id).order(created_at: :asc).last
            if form_custom_field.present?
              form_custom_field.update(form_entity_id: entity.id, entity_type: entity.entity_type, form_id: form.id)
            else
              FormCustomField.new({form_entity_id: entity.id, field_key: entity.entity_key, entity_type: entity.entity_type, document_type: gstin_location.class.name, document_id: gstin_location.id, form_id: form.id}).save
            end
          end
        end

        document.custom_fields.each do |custom_field|
          field_name = custom_field.field_configuration.field_name

          form_custom_field = document.form_custom_fields.where(field_key: field_name).order(updated_at: :asc).last
          if form_custom_field.present?
            if form_custom_field&.form_entity&.entity_type == "text"
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
        end

        # Reload document
        document.vendor_country = "India"
        document.save

        document.vendor_attachments.each do |old_attachment|
          # [nil, "others", "pan", "gstin", "cancelled_cheque", "", "pan_card", "tax_exemption", "msme_certificate", "lower_exemption"]
          case old_attachment.attachment_type
          when 'pan'
            relevant_custom_field = document.form_custom_fields.where(field_key: 'pan_attachment').order(created_at: :asc).last
          when 'gstin'
            relevant_custom_field = document.gstin_locations.first.form_custom_fields.where(field_key: 'gstin_certificate').order(created_at: :asc).last rescue nil
          when 'cancelled_cheque'
            relevant_custom_field = document.bank_accounts.first.form_custom_fields.where(field_key: 'cancelled_cheque').order(created_at: :asc).last rescue nil
          when 'tax_exemption'
            relevant_custom_field = document.form_custom_fields.where(field_key: 'tax_exemption_certificate').order(created_at: :asc).last
          when 'msme_certificate'
            relevant_custom_field = document.form_custom_fields.where(field_key: 'msme_registration_certificate').order(created_at: :asc).last
          when 'lower_exemption'
            relevant_custom_field = document.form_custom_fields.where(field_key: 'lower_exception_certificate').order(created_at: :asc).last
          else
            relevant_custom_field = document.form_custom_fields.where(field_key: 'other_documents').order(created_at: :asc).last
          end

          if relevant_custom_field.present?
            # va.yes_bank_vendor.form_custom_fields.where(field_key: :pan_attachment).order(created_at: :asc).last.attachments.where(attachment_file_name: va.attached_file_file_name)
            next if relevant_custom_field.attachments.where(attachment_file_name: old_attachment.attached_file_file_name).present?
            new_attachment = relevant_custom_field.attachments.new

            if Rails.env.production?
              begin
                new_attachment.attachment = old_attachment.attached_file
                new_attachment.save
              rescue Paperclip::AdapterRegistry::NoHandlerError => e
                attachment_error = "Company #{company.id} \n Document Type: #{document.class.name} \n Document ID: #{document.id} \n Attachment ID : #{old_attachment.id} \n Attachment Type: #{old_attachment.attachment_type} \n\n"
                puts attachment_error
                result.push(attachment_error)
              end
            else
              file_path = Rails.root.to_s + "/public" + old_attachment.attached_file.url(:original, false)
              file = File.open(file_path) rescue nil

              if file.present?
                new_attachment.attachment = old_attachment.attached_file
                new_attachment.save
              end
            end
          end
        end
      end

    end
    if Rails.env.production?
      File.open('/home/ubuntu/vendor_migration.log', 'w+') {|f| result.each {|line| f.puts(line)}}
    elsif Rails.env.staging?
      File.open('/home/centos/vendor_migration.log', 'w+') {|f| result.each {|line| f.puts(line)}}
    else
      File.open('/Users/kumar/Documents/vendor_migration.log', 'w+') {|f| result.each {|line| f.puts(line)}}
    end
  end
end
class NonPoInvoiceMigrator
  def self.perform(company_id)

    result = []

    company = Company.find company_id
    documents = Invoice.where(invoice_type_id: InwardInvoiceType.id_for(:non_po_invoice)).where(company_id: company.id)

    form = Form.where(klass_name: 'P2P::Docs::Invoices::Form', company_id: company_id).first

    documents.find_in_batches(batch_size: 1000) do |batch|
      batch.each do |document|

        # Populate Custom Fields
        form.entities.root.custom_fields.each do |entity|
          form_custom_field = FormCustomField.where(field_key: entity.entity_key, document_type: document.class.name, document_id: document.id).order(created_at: :asc).last
          if form_custom_field.present?
            form_custom_field.update(form_entity_id: entity.id, entity_type: entity.entity_type, form_id: form.id)
          else
            FormCustomField.new({form_entity_id: entity.id, field_key: entity.entity_key, entity_type: entity.entity_type, document_type: document.class.name, document_id: document.id, form_id: form.id}).save
          end
        end

        # Migrate Custom Fields
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

        # First migrate invoice line items
        document.items each do |item|
          update_params = {
              item_gross_amount: item.amount.value,
              item_gross_amount_converted: item.amount.value,
              item_discount_amount: item.discount.value,
              item_discount_amount_converted: item.discount.value,
              item_taxable_amount: item.taxable_amount.value,
              item_taxable_amount_converted: item.taxable_amount.value,
              item_net_amount: item.net_amount.value,
              item_net_amount_converted: item.net_amount.value,
              item_billable_amount: item.billable_amount.value,
              item_billable_amount_converted: item.billable_amount.value,

              # tds amount
              item_tds_amount: 0,
              item_tds_amount_converted: 0
          }

          item.update_columns(update_params)
        end

        # Migrate Invoice Data
        update_params = {
            # For the existing customers the base currency & reporting currency shall be 'INR'
            base_currency: "INR",
            reporting_currency: "INR",

            # Vendor Related Fields
            vendor_sequence_id: document.vendor&.vendor_id,
            vendor_trade_name: document.vendor&.display_name,
            vendor_pan: document.vendor&.pan,
            vendor_bank_account_number: document.receiving_account&.account_number,
            vendor_bank_account_ifsc: document.receiving_account&.ifsc,
            vendor_gstin: document.gstin_location&.gstin,

            # Amount Related Fields # todo - I2P check if amounts are getting saved properly
            invoice_gross_amount: document.amount.value,
            invoice_gross_amount_converted: document.amount.value,
            invoice_discount_amount: document.discount_amount.value,
            invoice_discount_amount_converted: document.discount_amount.value,
            invoice_taxable_amount: document.gross_amount.value,
            invoice_taxable_amount_converted: document.gross_amount.value,
            invoice_tax_amount: document.tax_amount.value,
            invoice_tax_amount_converted: document.tax_amount.value,
            invoice_tds_amount: document.tds_amount.value,
            invoice_tds_amount_converted: document.tds_amount.value,
            invoice_paid_outside_amount: document.advance_paid_amount.value,
            invoice_paid_outside_amount_converted: document.advance_paid_amount.value,
            invoice_sub_total_amount: document.net_amount.value,
            invoice_sub_total_amount_converted: document.net_amount.value,
            invoice_total_amount: document.net_amount.value,
            invoice_total_amount_converted: document.net_amount.value,
            invoice_freight_amount: document.freight_amount.value,
            invoice_freight_amount_converted: document.freight_amount.value,
            invoice_roundoff_amount: document.roundoff_amount,
            invoice_roundoff_amount_converted: document.roundoff_amount,
            invoice_balance_due: document.balance_due.value,
            invoice_balance_due_converted: document.balance_due.value
        }

        document.update_columns(update_params)

        # Migrate Attachments
        document.invoice_attachments.each do |old_attachment|
          relevant_custom_field = document.form_custom_fields.where(field_key: 'invoice_attachments')

          if relevant_custom_field.present?
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
    # Todo - I2P:
    # Log and output file for future reference; Will be useful in case data is not migrated properly
  end
end
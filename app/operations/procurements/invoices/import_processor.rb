class Procurements::Invoices::ImportProcessor < BackgroundOperation
  attr_accessor :invoices_params, :result

  def init
    self.invoices_params = params[:processed_invoices_params]
    self.result = {
        success: [],
        error: []
    }

  end

  def validate
    if invoices_params.blank?
      return
    end
  end

  def process
    self.invoices_params.each do |invoice_params|
      data_success = {}
      data_error = {}

      # Create procurement
      procurement_params = {
          procurement: {
              name: "Procurement - Invoice #{invoice_params[:invoice_number]}",
              vendor_id: invoice_params[:vendor_id]
          },
          document_type: 'non_po_invoice',
          invoice: invoice_params
      }

      op = Procurements::Create.(user, procurement_params)

      if op.success?
        # Update Invoice
        # invoice_parameters = get_invoices_parameters(invoice_params)


        new_invoice_params = {
            id: op.invoices&.first&.id,
            invoice: invoice_params
        }
        op2 = BankTransfer::InwardInvoices::Update.(user, new_invoice_params)

        unless op2.success?
          data_error[:invoice_details] = invoice_params
          data_error[:invoice_number] = invoice_params[:invoice_number]
          data_error[:messages] = op2.messages[:error]
        else
          data_success[:invoice_number] = invoice_params[:invoice_number]
          data_success[:messages] = ["Successfully Added Invoice"]
          if ["YES", "yes", "Yes", "Y", "y"].include?(invoice_params[:auto_submit])
            invoice_id = op.invoices&.first&.id
            op3 = Procurements::Invoices::Submit.(user, {id: invoice_id})

            unless op3.success?
              data_error[:messages] = op3.messages[:error]
            else
              data_success[:messages] = ["Successfully Added & Auto Submitted Invoice"]
            end
          end
        end
      else
        data_error[:messages] = op.messages[:error]
      end

      if data_error.present?
        self.result[:error].push(data_error)
      end

      if data_success.present?
        self.result[:success].push(data_success)
      end
    end
  end

  def post_process
    # Send mailer
    ::Event::EInvoice::BulkImport.(user, result: result)
  end
end
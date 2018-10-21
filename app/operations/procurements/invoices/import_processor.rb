class Procurements::Invoices::ImportProcessor < Procurements::Invoices::Base
  attr_accessor :invoices_params, :result

  def init
    self.invoices_params = params[:invoices_params]
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
              vendor_id: invoice_params[:vendor_id],
              document_type: 'invoice'
          },
          invoice: invoice_params
      }

      op = Procurements::Create.(user, procurement_params)

      if op.success?
        # Update Invoice

        invoice_parameters = get_invoices_parameters

        new_invoice_params = {
            id: op.invoices&.first&.id,
            invoice: invoice_parameters
        }
        op2 = BankTransfer::InwardInvoices::Update.(usser, new_invoice_params)

        unless op2.success?
          data_error[:invoice_details] = invoice_params
          data_error[:messages] = ["Couldn't add invoice"]
        else
          invoice_id = op.invoices&.first&.id
          op3 = Procurements::Invoices::Submit.(user, {id: invoice_id})

          unless op3.success?
            data_error[:messages] = op3.messages[:error]
          end
        end
      end

    end
  end
end
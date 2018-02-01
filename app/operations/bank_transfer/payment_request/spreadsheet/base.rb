class BankTransfer::PaymentRequest::Spreadsheet::Base < BankTransfer::PaymentRequest::Base

  attr_accessor :view_role, :bank_payment_requests,
                :headers, :field_configurations

  def retrieve_headers
    headers = ["Payment Order ID",
     "Payment Order Name",
     "Beneficiary Name",
     "Beneficiary Account Name",
     "Beneficiary Account Number",
     "Beneficiary IFSC",
     "Payment Mode",
     "Initiated By",
     "Status",
     "Awaiting Action From",
     "Invoice Number",
     "Invoice Due Date",
     "Invoice Date"]
    headers += retrieve_custom_field_headers
    headers += ["Invoice Amount",
     "Discount",
     "Tax",
     "TDS",
     "Advance",
     "Net Amount",
     "Bank Reference Number",
     "Note"]
  end

  def retrieve_data
    return [] if bank_payment_requests.empty?
    content = []
    bank_payment_requests.include_for_data_retrieval.each do |pr|
      po = pr.payment_order
      po.payments.each do |payment|
        payment_details = [
            pr.id,
            pr.name,
            "#{payment.receiving_account.account_owner.name}",
            "#{payment.receiving_account.name}",
            payment.receiving_account.account_number,
            payment.receiving_account.ifsc,
            payment.payment_mode&.upcase,
            payment.initiating_user.name,
            payment.payment_order.bank_payment_request.status&.name&.humanize,
            payment.payment_order.bank_payment_request.controlling_user&.name,
            payment.invoice&.invoice_number,
            payment.invoice&.due_date&.strftime("%d-%m-%Y"),
            payment.invoice&.date&.strftime("%d-%m-%Y")
        ]
        payment_details += retrieve_custom_fields(payment)
        payment_details += [
            (payment.invoice&.amount&.value || 0),
            (payment.invoice&.discount_amount&.value || 0),
            (payment.invoice&.tax_amount&.value || 0),
            (payment.invoice&.tds_amount&.value || 0),
            (payment.invoice&.advance_amount&.value || 0),
            (payment.amount&.value || 0),
            (payment.reference_resource&.bank_reference_number),
            payment.note
        ]
        content << payment_details
      end
    end
    content
  end

  def retrieve_custom_field_headers
    self.field_configurations = FieldConfiguration.with_company(user.company_id).non_deleted
    self.field_configurations.pluck(:field_name)
  end

  def retrieve_custom_fields(payment)
    values = []
    custom_fields = payment.invoice&.custom_fields
    self.field_configurations.each do |fc|
      if custom_fields.present?
        values << custom_fields.with_field_configuration_ids(fc.id).first&.string_value
      else
        values << ""
      end
    end
    values
  end
end
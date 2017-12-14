class BankTransfer::PaymentRequest::Spreadsheet::Base < BankTransfer::PaymentRequest::Base

  attr_accessor :view_role, :bank_payment_requests,
                :headers, :con

  def retrieve_headers
    ["Beneficiary Name",
     "Beneficiary Account Number",
     "Beneficiary IFSC",
     "Payment Mode",
     "Initiated By",
     "Invoice Number",
     "Invoice Due Date",
     "Invoice Date",
     "Invoice Amount",
     "Discount",
     "Tax",
     "TDS",
     "Net Amount",
     "Bank Reference Number",
     "Note"]
  end

  def retrieve_data
    return [] if bank_payment_requests.empty?
    content = []
    bank_payment_requests.each do |pr|
      po = pr.payment_order
      po.payments.each do |payment|
        content << [
            payment.receiving_account.name,
            payment.receiving_account.account_number,
            payment.receiving_account.ifsc,
            payment.payment_mode&.upcase,
            payment.initiating_user.name,
            payment.invoice&.invoice_number,
            payment.invoice&.due_date&.strftime("%d-%m-%Y"),
            payment.invoice&.date&.strftime("%d-%m-%Y"),
            (payment.invoice&.amount&.value || 0),
            (payment.invoice&.discount_amount&.value || 0),
            (payment.invoice&.tax_amount&.value || 0),
            (payment.invoice&.tds_amount&.value || 0),
            (payment.amount&.value || 0),
            (payment.reference_resource&.bank_reference_number),
            payment.note
        ]
      end
    end
    content
  end
end
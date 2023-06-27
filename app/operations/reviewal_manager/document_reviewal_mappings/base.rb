class ReviewalManager::DocumentReviewalMappings::Base < BaseOperation

  def get_document_amount
    # Different kind of documents have base amount stored in different attributes which is used in 
    # threshold in level reviewer mapping
    amount = 0

    case document.class.name
    when 'PurchaseOrder'
      amount = document&.reporting_po_balance_due rescue 0
    when 'MoneyRequest'
      amount = document&.total_amount
    when 'Invoice'
      amount = document.reporting_invoice_sub_total_amount || document.invoice_total_amount rescue 0
    when 'Report'
      amount = document&.total_amount rescue 0
    when 'BankPaymentRequest'
      amount = (document&.payment_order&.reporting_amount_requested.truthy? ? document&.payment_order&.reporting_amount_requested : document&.payment_order&.amount_requested&.value) rescue 0
    # when 'TravelRequest'
    #   amount = 0
    when 'PurchaseRequest'
      amount = document&.total_amount&.value
    when 'PaymentAgreement'
      amount = document.total_amount.value rescue 0
    when 'BbpsBillerSubscription'
      amount = 0
    when 'BbpsBill'
      amount = document.amount.value rescue 0
    when 'CreditNote'
      amount = document.net_adjustable_amount.value rescue 0
    when 'YesBankVendor'
      amount = 1
    else
      amount = 0
    end
    amount
  end

  private

  # def get_po_total
  #
  # end
  #
  # def get_invoice_total
  #
  # end
end

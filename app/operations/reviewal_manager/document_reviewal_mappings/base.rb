class ReviewalManager::DocumentReviewalMappings::Base < BaseOperation

  def get_document_amount
    # Different kind of documents have base amount stored in different attributes which is used in 
    # threshold in level reviewer mapping
    amount = 0

    case document.class.name
      when 'PurchaseOrder'
        amount = document&.balance_amount&.value rescue 0
      when 'Invoice'
        amount = document&.net_amount&.value rescue 0
      else
        amount = 0
    end

    amount
  end
end

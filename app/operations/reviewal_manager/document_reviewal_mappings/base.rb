class ReviewalManager::DocumentReviewalMappings::Base < BaseOperation

  def get_document_amount
    # Different kind of documents have base amount stored in different attributes which is used in 
    # threshold in level reviewer mapping
    amount = 0

    case document.class.name
      when 'PurchaseOrder'
        amount = get_po_total
      when 'Invoice'
        amount = document&.net_amount&.value rescue 0
      else
        amount = 0
    end
    amount
  end

  private

  def get_po_total
    total_amount = 0
    items = params[:purchase_order][:items_attributes]
    items.each do |item|
      quantity = item[:quantity].to_f
      rate = item[:rate].to_f
      discount_percent = item[:discount].to_f
      tax_rate = ::TaxRate.find_by id: item[:tax_rate_id] rescue nil
      tax_percent = tax_rate.present? ? tax_rate.rate : 0

      amount = quantity * rate
      taxable_amount = amount - (amount * discount_percent / 100)
      final_amount = taxable_amount + (taxable_amount * tax_percent / 100)

      total_amount += final_amount
    end

    roundoff_amount = params[:purchase_order][:roundoff_amount].to_f

    if roundoff_amount.abs < 1.0
      total_amount = precision_value(total_amount) +  precision_value(roundoff_amount)
    end

    total_amount
  end

  def get_invoice_total

  end
end

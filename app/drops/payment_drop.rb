class PaymentDrop < Drop

  def date
    record.date
  end

  def processed_at
    record.processed_at
  end

  def narration
    record.note
  end

  def reference_id
    record.external_reference_id
  end

  def gl_name
    record.gl_name
  end

  def vendor
    return nil unless record.receiving_user_type == "YesBankVendor"

    record.receiving_user&.to_liquid
  end

  def beneficiary
    vendor
  end

  def amount
    record.amount&.value || 0
  end

  def utr
    record.utr rescue nil
  end

  def parent
    record.parent
  end

  def invoice
    return nil unless record.parent_type == 'Invoice'

    record.parent
  end

  def purchase_order
    return nil unless record.parent_type == "PurchaseOrder"

    record.parent
  end

  def beneficiary_payment
    return nil unless record.parent_type == 'BeneficiaryPayment'

    record.parent
  end

end
class PaymentExposure < Exposures::API

  def date
    record.date
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

end
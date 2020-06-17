class BeneficiaryPaymentExposure < Exposures::API

  attribute :tax_amount, record_attribute: true, exposure: true
  attribute :cgst_amount do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      (record.tax_amount&.value || 0) / 2
    when GstType.id_for(:igst)
      0
    end
  end
  attribute :sgst_amount do
    cgst_amount
  end
  attribute :igst_amount do
    case record.gst_type_id
    when GstType.id_for(:cgst_sgst)
      0
    when GstType.id_for(:igst)
      record.tax_amount&.value
    end
  end

end

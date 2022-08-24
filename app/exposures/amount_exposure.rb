class AmountExposure < Exposures::API

  attribute :value, record_attribute: true
  attribute :currency, record_attribute: true, exposure: true
  attribute :currency_format, record_attribute: false do
    '%2f' % record.value
  end

end
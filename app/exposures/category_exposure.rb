class CategoryExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :category_code, record_attribute: true
  attribute :gl_code, record_attribute: true

  attribute :gl_code_or_item_number do
    if record.gl_code.present?
      record.gl_code
    else
      registers["item_number"]
    end
  end

  attribute :full_name do
    record.full_name
  end

end
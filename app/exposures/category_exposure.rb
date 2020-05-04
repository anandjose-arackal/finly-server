class CategoryExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :category_code, record_attribute: true
  attribute :gl_code, record_attribute: true

end
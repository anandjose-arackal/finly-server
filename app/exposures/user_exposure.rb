class UserExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :first_name, record_attribute: true
  attribute :last_name, record_attribute: true
  attribute :email, record_attribute: true
  attribute :mobile_number, record_attribute: true

end

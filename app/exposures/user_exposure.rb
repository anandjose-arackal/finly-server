class UserExposure < Exposures::API

  attribute :name, record_attribute: true
  attribute :first_name, record_attribute: true
  attribute :last_name, record_attribute: true
  attribute :email, record_attribute: true

end

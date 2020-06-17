class Masters::Users::Lookup < Lookup::API

  resolver 'users.default'
  search_key :first_name_or_last_name_or_email_or_mobile_number_cont

  attribute :id, visible: false
  attribute :name
  attribute :email

end
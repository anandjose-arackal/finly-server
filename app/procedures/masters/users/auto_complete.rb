class Masters::Users::AutoComplete < Lookup::API

  resolver 'users.default'
  json :id, :name
  search_key :first_name_or_last_name_or_email_or_mobile_number_cont

end
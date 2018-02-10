json.array!(@result.addresses) do |address|
  json.extract! address, :name, :line_1, :line_2, :line_3, :city, :state_id,
                              :name, :pin_code, :default, :id, :address_name, :landmark
end
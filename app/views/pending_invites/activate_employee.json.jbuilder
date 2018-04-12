json.verified @pending_user.otp_verified
json.id @pending_user.id
json.mobile_number @pending_user.mobile_number
json.company_name @pending_user.company.name
json.states do
  json.array!(@states) do |state|
    json.id state.id
    json.name state.name
  end
end
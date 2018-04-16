if @pending_user
  json.success true
  json.id @pending_user.id
  json.email @pending_user.email
  json.company_name @pending_user.company.name
  json.states do
    json.array!(@states) do |state|
      json.id state.id
      json.name state.name
    end
  end
else
  json.success false
  json.message 'Invalid or expired token'
end
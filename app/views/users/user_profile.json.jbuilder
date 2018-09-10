json.company current_user.company.name
json.email current_user.email
json.name current_user.name
json.mobile_number current_user.mobile_number
json.address current_user.profile&.full_address
json.user_delegate do
  json.user_delegate_id current_user.user_delegate&.id
  json.user_delegate_name current_user.user_delegate&.name
  json.delegation_enabled current_user.delegation_enabled
  json.user_delegate_email current_user.user_delegate&.email
  json.user_delegate_email current_user.user_delegate&.mobile_number
end

profile = current_user.profile
if current_user.profile.signature.present?

  json.signature do
    json.file_name profile.signature_file_name
    json.url profile.signature.url
  end
end

json.signature_title profile.signature_title

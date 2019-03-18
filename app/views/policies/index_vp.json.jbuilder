if RequestStore[:current_user].vendor_payment_admin?
  json.array! @result.admin_policies, :id, :name
else
  json.array! @result.policies, :id, :name
end
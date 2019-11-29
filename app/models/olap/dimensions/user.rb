class Olap::Dimensions::User < OlapRecord
  include Analytics::Mapper

  transaction_model ::User
  events 'user.update', 'user.create', 'user.destroy'

  map :email
  map :employee_id do record.profile.employee_id end
  map :kyc_verified do record.profile.kyc_verified end
  map :company_id
  map :mobile_number
  map :active
  map :otp_verified
  map :first_name
  map :last_name
  map :mobile_only_invite
  map :verified
  map :default_password
  map :point_of_contact
  map :password_changed_at
  map :last_activity_at
  map :expired_at
  map :cost_center_id
  map :department_id
  map :location_id
  map :default_company_id
  map :finly_id

end

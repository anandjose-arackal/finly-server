# == Schema Information
#
# Table name: olap_dimensions_users
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  email                :string(255)
#  employee_id          :string(255)
#  kyc_verified         :boolean
#  company_id           :integer
#  mobile_number        :string(255)
#  active               :boolean
#  otp_verified         :boolean
#  first_name           :string(255)
#  last_name            :string(255)
#  mobile_only_invite   :boolean
#  verified             :boolean
#  default_password     :boolean
#  point_of_contact     :boolean
#  password_changed_at  :datetime
#  last_activity_at     :datetime
#  expired_at           :datetime
#  cost_center_id       :integer
#  department_id        :integer
#  location_id          :integer
#  default_company_id   :integer
#  finly_id             :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  uuid                 :string(36)       not null
#

class Olap::Dimensions::User < OlapRecord
  include Analytics::Mapper

  transaction_model ::User
  events 'user.update', 'user.create', 'user.destroy'

  required_relationships([:profile])

  map :email
  map :employee_id do |input, record|
    record.profile&.employee_id
  end
  map :kyc_verified do |input, record|
    record.profile&.kyc_verified
  end
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

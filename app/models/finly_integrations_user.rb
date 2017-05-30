# == Schema Information
#
# Table name: finly_integrations_users
#
#  id                              :integer          not null, primary key
#  email                           :string(255)
#  name                            :string(255)
#  mobile_number                   :string(255)
#  external_id                     :string(255)
#  external_integration_type       :string(255)
#  external_updated_at             :datetime
#  active                          :boolean
#  external_additional_information :text(65535)
#  user_id                         :integer
#  company_id                      :integer
#  external_user_type              :string(255)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class FinlyIntegrationsUser < ActiveRecord::Base
  include FinlyIntegratable
  QUICKBOOKS_USER_TYPES = ['Employee', 'Vendor']

  validates :email, presence: true

  validates :external_user_type, inclusion: { in: QUICKBOOKS_USER_TYPES }, if: proc {|finly_external_user| finly_external_user.external_integration_type == FinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0] }

  belongs_to :user
  belongs_to :company

  # def save
  #   if self.valid?
  #     begin
  #       finly_user = User.find_or_initialize_by(external_integration_type: self.external_integration_type,
  #         external_id: self.external_id)
  #       finly_user.tap do |user|
  #         user.email = self.email
  #         user.company_id = self.company_id
  #         user.name = self.name
  #         user.mobile_number = self.mobile_number
  #         user.external_updated_at = self.external_updated_at
  #         user.active = self.active
  #         user.external_additional_information = self.external_additional_information
  #       end
  #       finly_user.save
  #     rescue ActiveRecord::RecordNotUnique
  #       retry
  #     end
  #   else
  #     return false
  #   end
  # end
end

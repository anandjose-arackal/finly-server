# == Schema Information
#
# Table name: quickbooks_finly_integrations_users
#
#  id                                :integer          not null, primary key
#  email                             :string(255)
#  name                              :string(255)
#  mobile_number                     :string(255)
#  quickbooks_id                     :string(255)
#  quickbooks_integration_type       :string(255)
#  quickbooks_updated_at             :datetime
#  active                            :boolean
#  quickbooks_additional_information :text(65535)
#  user_id                           :integer
#  company_id                        :integer
#  quickbooks_user_type              :string(255)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

class QuickbooksFinlyIntegrationsUser < ActiveRecord::Base
  include QuickbooksFinlyIntegratable
  QUICKBOOKS_USER_TYPES = ['Employee', 'Vendor']

  validates :email, presence: true

  validates :quickbooks_user_type, inclusion: { in: QUICKBOOKS_USER_TYPES }, if: proc {|finly_external_user| finly_external_user.quickbooks_integration_type == QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0] }

  belongs_to :user
  belongs_to :company

  # adds the relevant details to the User model and saves it in the db
  def save
    if self.valid?
      begin
        finly_user = User.find_by(email: self.email) || User.find_by(mobile_number: self.mobile_number)
        if finly_user
          finly_user.tap do |user|
            user.quickbooks_id = self.quickbooks_id
            user.quickbooks_integration_type = self.quickbooks_integration_type
            user.quickbooks_updated_at = self.quickbooks_updated_at
            user.quickbooks_additional_information = self.quickbooks_additional_information
          end
          finly_user.save
        end
      rescue ActiveRecord::RecordNotUnique
        # retry
      end
    else
      return false
    end
  end
end

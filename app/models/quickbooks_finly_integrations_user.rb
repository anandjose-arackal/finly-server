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

class QuickbooksFinlyIntegrationsUser < ApplicationRecord
  QUICKBOOKS_USER_TYPES = ['Employee', 'Vendor']

  validates :email, presence: true

  validates :quickbooks_user_type, inclusion: { in: QUICKBOOKS_USER_TYPES }, if: proc {|finly_external_user| finly_external_user.quickbooks_integration_type == QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0] }

  belongs_to :user, optional: true
  belongs_to :company, optional: true

  # adds the relevant details to the User model and saves it in the db
  def save
    if self.valid?
      finly_user = nil
      finly_user = User.find_by(email: self.email, company_id: self.company_id) unless self.email.blank?
      if finly_user.blank?
        finly_user = User.find_by(mobile_number: self.mobile_number, company_id: self.company_id) unless self.mobile_number.blank?
      end
      if finly_user
        if finly_user.quickbooks_user.present?
          qb_user = finly_user.quickbooks_user
          qb_user.destroy
          self.user = finly_user
          self.company = finly_user.company
          super
        else
          # now create the corresponding quickbooks_integrations_user from this data
          self.user = finly_user
          self.company = finly_user.company
          super
        end
      end
    else
      return false
    end
  end
end

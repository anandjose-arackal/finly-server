# == Schema Information
#
# Table name: user_permissions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  company_id           :integer
#  create_beneficiaries :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  edit_terms_within_po :boolean          default(FALSE)
#

class UserPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

  def create_beneficiaries
    super || self.user.vendor_payments_admin?
  end

end

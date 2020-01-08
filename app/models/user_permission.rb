# == Schema Information
#
# Table name: user_permissions
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  company_id                 :integer
#  create_beneficiaries       :boolean
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  edit_terms_within_po       :boolean          default(FALSE)
#  crud_inventory_item_po     :boolean          default(TRUE)
#  crud_inventory_item_non_po :boolean          default(TRUE)
#

class UserPermission < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  def create_beneficiaries
    super || self.user.vendor_payments_admin?
  end

end

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
#  crud_inventory_item_po     :boolean
#  crud_inventory_item_non_po :boolean
#

require 'test_helper'

class UserPermissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

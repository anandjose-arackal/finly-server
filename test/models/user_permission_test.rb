# == Schema Information
#
# Table name: user_permissions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  company_id           :integer
#  crud_beneficiary     :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  edit_terms_within_po :boolean          default(FALSE)
#

require 'test_helper'

class UserPermissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

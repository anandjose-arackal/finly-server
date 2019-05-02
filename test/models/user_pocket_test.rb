# == Schema Information
#
# Table name: user_pockets
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  balance_id                 :integer
#  user_pocket_type_id        :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  account_code               :string(255)
#  atm_withdrawal_pocket      :boolean          default(FALSE)
#  user_id                    :integer
#  base_currency_id           :integer
#  company_pocket_template_id :integer
#  active                     :boolean          default(TRUE)
#

require 'test_helper'

class UserPocketTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

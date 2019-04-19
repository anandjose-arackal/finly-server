# == Schema Information
#
# Table name: tally_configurations
#
#  id                   :integer          not null, primary key
#  company_id           :integer          not null
#  company_name         :string(255)
#  active               :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  voucher_expense_date :string(255)
#  custom_voucher       :boolean          default(FALSE)
#  excel_export         :boolean          default(FALSE)
#

require 'test_helper'

class TallyConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

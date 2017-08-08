# == Schema Information
#
# Table name: company_funds_load_requests
#
#  id                   :integer          not null, primary key
#  company_id           :integer
#  requested_by_user_id :integer          not null
#  reference_id         :string(255)      not null
#  date                 :date             not null
#  amount_id            :integer
#  remark               :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  bank_type_id         :integer
#  is_active            :boolean          default(TRUE)
#

require 'test_helper'

class CompanyFundsLoadRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

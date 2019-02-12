# == Schema Information
#
# Table name: tax_rates
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  rate        :decimal(20, 5)
#  internal_id :string(255)
#  company_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_deleted  :boolean          default(FALSE), not null
#  deleted_at  :datetime
#

require 'test_helper'

class TaxRateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

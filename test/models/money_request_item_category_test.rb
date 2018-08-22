# == Schema Information
#
# Table name: money_request_item_categories
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  name       :string(255)      not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class MoneyRequestItemCategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

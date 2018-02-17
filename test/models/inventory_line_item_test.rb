# == Schema Information
#
# Table name: inventory_line_items
#
#  id          :integer          not null, primary key
#  tax         :decimal(10, 5)
#  discount    :decimal(10, 5)
#  hsn_sac     :string(255)
#  company_id  :integer
#  sku         :string(255)
#  rate        :decimal(10, 5)
#  description :text(65535)
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  note        :text(65535)
#

require 'test_helper'

class InventoryLineItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

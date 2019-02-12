# == Schema Information
#
# Table name: inventory_line_items
#
#  id                  :integer          not null, primary key
#  tax                 :decimal(20, 10)
#  discount            :decimal(20, 10)
#  hsn_sac             :string(255)
#  company_id          :integer
#  sku                 :string(255)
#  rate                :decimal(20, 10)
#  description         :text(65535)
#  category_id         :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  note                :text(65535)
#  tax_rate_id         :integer
#  is_deleted          :boolean          default(FALSE), not null
#  item_code           :string(255)
#  account             :string(255)
#  supply_item_type_id :integer
#  deleted_at          :datetime
#

require 'test_helper'

class InventoryLineItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

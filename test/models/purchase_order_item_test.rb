# == Schema Information
#
# Table name: purchase_order_items
#
#  id                     :integer          not null, primary key
#  purchase_order_id      :integer
#  inventory_line_item_id :integer
#  product_id             :string(255)
#  description            :string(255)
#  hsn_sac                :string(255)
#  quantity               :integer
#  rate                   :decimal(10, 5)
#  tax                    :decimal(10, 5)
#  tds                    :decimal(10, 5)
#  discount               :decimal(10, 5)
#  tax_amount_id          :integer
#  tds_amount_id          :integer
#  discount_amount_id     :integer
#  total_amount_id        :integer
#  delivery_date          :date
#  comment                :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  delivered              :integer          default(0)
#  accepted               :integer          default(0)
#  rejected               :integer          default(0)
#

require 'test_helper'

class PurchaseOrderItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

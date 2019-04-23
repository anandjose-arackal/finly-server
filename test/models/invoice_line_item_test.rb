# == Schema Information
#
# Table name: invoice_line_items
#
#  id                     :integer          not null, primary key
#  invoice_id             :integer
#  description            :string(255)
#  quantity               :integer
#  rate                   :decimal(20, 10)
#  tax                    :decimal(20, 10)
#  discount               :decimal(20, 10)
#  category_id            :integer
#  gst_type_id            :integer
#  tax_amount_id          :integer
#  discount_amount_id     :integer
#  amount_id              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  net_amount_id          :integer
#  hsn_sac                :string(255)
#  taxable_amount_id      :integer
#  parent_type            :string(255)
#  parent_id              :string(255)
#  inventory_line_item_id :integer
#  item_info              :text(65535)
#  comment                :text(65535)
#  account                :string(255)
#  tax_rate_id            :integer
#  cost_center_id         :integer
#

require 'test_helper'

class InvoiceLineItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: inward_document_items
#
#  id                     :integer          not null, primary key
#  purchase_order_item_id :integer
#  inward_document_id     :integer
#  inventory_line_item_id :integer
#  product_id             :string(255)
#  description            :string(255)
#  quantity               :decimal(10, )
#  delivered              :decimal(10, )
#  accepted               :decimal(10, )
#  rejected               :decimal(10, )
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class InwardDocumentItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

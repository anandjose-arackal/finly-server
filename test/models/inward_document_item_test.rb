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
#  quantity               :decimal(20, 5)
#  delivered              :decimal(20, 5)
#  accepted               :decimal(20, 5)
#  rejected               :decimal(20, 5)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  comment                :string(255)
#  previously_delivered   :decimal(20, 5)
#  is_deleted             :boolean          default(FALSE), not null
#  deleted_at             :datetime
#

require 'test_helper'

class InwardDocumentItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: purchase_orders
#
#  id                           :integer          not null, primary key
#  company_id                   :integer
#  procurement_id               :integer
#  location_id                  :integer
#  delivery_location_id         :integer
#  vendor_id                    :integer
#  payment_term_id              :integer
#  procurement_term_id          :integer
#  purchase_order_status_id     :integer
#  indent_number                :string(255)
#  indent_date                  :date
#  po_number                    :string(255)
#  override_po_number           :boolean
#  prefix                       :string(255)
#  sequence_start               :string(255)
#  delivery_date                :date
#  gst_type_id                  :integer
#  inclusive_of_taxes           :boolean
#  roundoff_total_enabled       :boolean
#  roundoff_amount              :decimal(10, 5)
#  transaction_amount_id        :integer
#  total_before_tax_id          :integer
#  tax_amount_id                :integer
#  total_after_tax_id           :integer
#  discount_amount_id           :integer
#  balance_amount_id            :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :integer
#  procurement_term_text        :text(65535)
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  policy_id                    :integer
#  controlling_level_id         :integer
#  department_id                :integer
#  is_deleted                   :boolean          default(FALSE), not null
#  cost_center_id               :integer
#  sub_department_id            :integer
#  billing_address              :text(65535)
#  shipping_address             :text(65535)
#  is_template                  :boolean          default(FALSE)
#  template_name                :string(255)
#  resource_template_id         :integer
#  deleted_at                   :datetime
#  submitted_at                 :datetime
#  approved_at                  :datetime
#

require 'test_helper'

class PurchaseOrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

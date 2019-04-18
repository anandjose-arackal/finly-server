# == Schema Information
#
# Table name: purchase_request_items
#
#  id                           :bigint(8)        not null, primary key
#  purchase_request_id          :integer
#  item_id                      :integer
#  vendor_id                    :integer
#  delivery_location_id         :integer
#  purpose                      :text(65535)
#  quantity                     :decimal(20, 5)
#  per_unit_estimated_amount_id :integer
#  estimated_amount_id          :integer
#  required_by_date             :date
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  approved                     :boolean
#  status_id                    :integer
#  purchase_order_id            :integer
#  rejected                     :boolean
#  unit_of_measurement          :string(255)
#  reject_note                  :string(255)
#

require 'rails_helper'

RSpec.describe PurchaseRequestItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: bbps_bills
#
#  id                         :bigint           not null, primary key
#  subscription_id            :integer
#  user_id                    :integer
#  name                       :string(255)
#  sequence_id                :string(255)
#  department_id              :integer
#  cost_center_id             :integer
#  location_id                :integer
#  policy_id                  :integer
#  controlling_level_id       :integer
#  status_id                  :integer
#  amount_id                  :integer
#  autofetched                :boolean          default(FALSE)
#  expected_due_date          :date
#  deleted_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  submitted_at               :datetime
#  approved_at                :datetime
#  note                       :text(65535)
#  company_id                 :integer
#  category_id                :integer
#  due_date                   :date
#  bill_date                  :date
#  bill_number                :string(255)
#  paid_on_date               :date
#  transaction_id             :string(255)
#  bbps_id                    :string(255)
#  bill_period                :string(255)
#  late_payment_fee_id        :integer
#  early_payment_fee_id       :integer
#  convenience_fee_id         :integer
#  quick_pay                  :string(255)      default("N")
#  total_amount_id            :integer
#  early_payment_fee_selected :boolean          default(FALSE)
#  late_payment_fee_selected  :boolean          default(FALSE)
#  convenience_fee_selected   :boolean          default(FALSE)
#  bbps_biller_id             :integer
#  bill_validation_required   :boolean
#  order_number               :string(255)
#  order_number_type          :string(255)
#  tax_rate_id                :integer
#  hsn_sac                    :string(255)
#  paid_at                    :datetime
#  review_note                :text(65535)
#

require 'rails_helper'

RSpec.describe BbpsBill, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

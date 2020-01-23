# == Schema Information
#
# Table name: credit_notes
#
#  id                            :bigint           not null, primary key
#  company_id                    :integer
#  user_id                       :integer
#  invoice_id                    :integer
#  procurement_id                :integer
#  status_id                     :integer
#  controlling_level_id          :integer
#  policy_id                     :integer
#  vendor_id                     :integer
#  shipping_location_id          :integer
#  billing_location_id           :integer
#  sequence_id                   :string(255)
#  credit_note_date              :date
#  narration                     :text(65535)
#  billing_address               :text(65535)
#  shipping_address              :text(65535)
#  gross_receivable_amount_id    :integer
#  tax_amount_id                 :integer
#  discount_amount_id            :integer
#  net_receivable_amount_id      :integer
#  tds_rate_id                   :integer
#  tds_amount_id                 :integer
#  freight_amount_id             :integer
#  previously_adjusted_amount_id :integer
#  net_adjustable_amount_id      :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  deleted_at                    :datetime
#  roundoff_amount_id            :integer
#  department_id                 :integer
#  cost_center_id                :integer
#  submitted_at                  :datetime
#  approved_at                   :datetime
#  credit_note_number            :string(255)
#  last_adjusted_at              :datetime
#

require 'rails_helper'

RSpec.describe CreditNote, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

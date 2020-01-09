# == Schema Information
#
# Table name: procurement_charges
#
#  id              :integer          not null, primary key
#  charge_type     :integer
#  description     :string(255)
#  amount_id       :integer
#  taxable         :boolean
#  tax             :decimal(10, )
#  tax_amount_id   :integer
#  total_amount_id :integer
#  chargable_id    :integer
#  chargable_type  :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ProcurementCharge < ApplicationRecord
  belongs_to :amount, optional: true
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :total_amount, optional: true, class_name: "Amount"
  belongs_to :chargable, optional: true, polymorphic: true

end

# == Schema Information
#
# Table name: enforce_budget_configurations
#
#  id                            :integer          not null, primary key
#  enforce_purchase_order_budget :boolean
#  enforce_payment_budget        :boolean
#  enforce_expense_budget        :boolean
#  enforce_invoice_budget        :boolean
#  company_id                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class EnforceBudgetConfiguration < ApplicationRecord

  belongs_to :company, optional: true
end

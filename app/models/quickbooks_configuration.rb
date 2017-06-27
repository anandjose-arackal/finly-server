# == Schema Information
#
# Table name: quickbooks_configurations
#
#  id                              :integer          not null, primary key
#  default_quickbooks_payment_type :string(255)
#  user_id                         :integer
#  auto_import                     :boolean
#  auto_export                     :boolean
#  transaction_date_field          :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  quickbooks_payment_type_id      :integer
#  reimbursable_account_id         :integer
#  non_reimbursable_account_id     :integer
#  company_id                      :integer
#

# one instance of this will exist for every company

class QuickbooksConfiguration < ActiveRecord::Base

  belongs_to :quickbooks_payment_type
  belongs_to :company
  belongs_to :reimbursable_account, class_name: 'QuickbooksPaymentType'
  belongs_to :non_reimbursable_account, class_name: 'QuickbooksPaymentType'

  TRANSACTION_DATE_FIELD_TYPES = {
      1 => "Start Date",
      2 => "End Date"
  }

  def quickbooks_expense_date

  end

end

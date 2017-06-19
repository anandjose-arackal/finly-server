# == Schema Information
#
# Table name: quickbooks_configurations
#
#  id                              :integer          not null, primary key
#  default_quickbooks_payment_type :string(255)
#  user_id                         :integer
#  auto_import                     :boolean
#  auto_export                     :boolean
#  transaction_date_field          :string(255)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  quickbooks_payment_type_id      :integer
#  reimbursable_account_id         :integer
#  non_reimbursable_account_id     :integer
#

# an instance of this class will have to be created for every user trying to sync reports - i.e. ideally the admins

class QuickbooksConfiguration < ActiveRecord::Base
  belongs_to :quickbooks_payment_type
  belongs_to :company
  belongs_to :reimbursable_account, class_name: 'QuickbooksPaymentType'
  belongs_to :non_reimbursable_account, class_name: 'QuickbooksPaymentType'

  def quickbooks_expense_date

  end
end

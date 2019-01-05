# == Schema Information
#
# Table name: transaction_details
#
#  id                       :integer          not null, primary key
#  transaction_reference_id :string(255)
#  payment_purpose          :string(255)
#  merchant                 :string(255)
#  note                     :text(16777215)
#  transaction_type         :string(255)
#  status                   :string(255)
#  amount_id                :integer
#  finly_transaction_id     :integer
#  opening_balance_id       :integer
#  closing_balance_id       :integer
#  company_id               :integer
#  transaction_date         :datetime
#  sequence_number          :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class TransactionDetail < ApplicationRecord

  belongs_to :company, optional: true
  belongs_to :finly_transaction, optional: true
  belongs_to :opening_balance, optional: true, class_name: 'Amount'
  belongs_to :closing_balance, optional: true, class_name: 'Amount'

  validates :finly_transaction_id, uniqueness: true

end

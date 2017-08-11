# == Schema Information
#
# Table name: finly_transactions
#
#  id                          :integer          not null, primary key
#  finly_account_id            :integer          not null
#  finly_account_type          :string(255)      not null
#  transaction_type_id         :integer          not null
#  amount_id                   :integer          not null
#  transaction_reference_id    :string(255)      not null
#  status_id                   :integer          not null
#  payment_purpose_id          :integer          not null
#  opening_balance_id          :integer
#  closing_balance_id          :integer
#  associated_transaction_id   :integer
#  associated_transaction_type :string(255)
#  payment_id                  :integer
#  company_id                  :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class FinlyTransaction < ActiveRecord::Base
  belongs_to :finly_account, polymorphic: true
  belongs_to :transaction_type
  belongs_to :amount
  belongs_to :status, class_name: 'TransactionStatus'
  belongs_to :payment_purpose
  belongs_to :opening_balance, class_name: 'Amount'
  belongs_to :closing_balance, class_name: 'Amount'
  belongs_to :associated_transaction, polymorphic: true
  belongs_to :payment
  belongs_to :company
  has_many :system_messages

  accepts_nested_attributes_for :amount, :opening_balance, :closing_balance

  validates :finly_account_id, presence: true
  validates :finly_account_type, presence: true, :inclusion => {:in => AccountManagerUtils.available_accounts(format: :string)}
  validates :transaction_type_id, presence: true
  validates :transaction_reference_id, presence: true
  validates :company_id, presence: true
  validates :status_id, presence: true
  validates :payment_purpose_id, presence: true

end

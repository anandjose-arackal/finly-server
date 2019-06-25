# == Schema Information
#
# Table name: kotak_bank_transactions
#
#  id                         :bigint           not null, primary key
#  amount_id                  :integer
#  company_id                 :integer
#  transfer_status_id         :integer
#  beneficiary_account_id     :integer
#  utr                        :string(255)
#  response_status_code       :string(255)
#  unique_reference_number    :string(255)
#  transfer_type              :string(255)
#  beneficiary_account_number :string(255)
#  beneficiary_account_ifsc   :string(255)
#  beneficiary_name           :string(255)
#  narration                  :string(255)
#  payment_date               :date
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class KotakBankTransaction < ApplicationRecord
  belongs_to :amount
  belongs_to :company
  belongs_to :beneficiary_account, class_name: 'BankAccount'
  belongs_to :transfer_status, class_name: 'BankTransferStatus', optional: true

  has_one :payment, as: :reference_resource

  validates :unique_reference_number, presence: true
  validates :amount_id, presence: true

  delegate :amount_value, to: :amount
  delegate :completed?, :processing?, :failed, :retriable?, :open?, :possible_failure?, :pending_for_processing?, :suspect?, to: :transfer_status

  accepts_nested_attributes_for :amount
end

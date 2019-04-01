# == Schema Information
#
# Table name: icici_bank_transactions
#
#  id                    :bigint(8)        not null, primary key
#  aggr_id               :string(255)
#  aggr_name             :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corp_id               :string(255)
#  user_id               :string(255)
#  debit_acc             :string(255)
#  credit_acc            :string(255)
#  txn_type              :string(255)
#  amount_id             :integer
#  ifsc                  :string(255)
#  receiving_account_id  :integer
#  otp                   :string(255)
#  payee_name            :text(65535)
#  remarks               :text(65535)
#  customer_induced      :boolean
#  transfer_type         :string(255)
#  unique_request_number :string(255)
#  utr                   :string(255)
#  transfer_status_id    :integer
#  company_id            :integer
#  request_id            :string(255)
#

class IciciBankTransaction < ApplicationRecord
  belongs_to :amount
  belongs_to :receiving_account, class_name: "BankAccount"
  belongs_to :transfer_status, optional: true, class_name: "BankTransferStatus"
  belongs_to :bank_transaction_type, optional: true

  has_one :payment, as: :reference_resource

  validates :unique_request_number, presence: true
  validates :amount_id, presence: true

  accepts_nested_attributes_for :amount

  alias_method :bank_reference_number, :utr
end

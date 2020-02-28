# == Schema Information
#
# Table name: icici_bank_transactions
#
#  id                    :bigint           not null, primary key
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
#  deleted_at            :datetime
#  transfer_mode_id      :integer
#  reference_payment_id  :integer
#  bank_error_message    :text(16777215)
#

class IciciBankTransaction < ApplicationRecord
  belongs_to :amount, optional: true
  belongs_to :receiving_account, class_name: "BankAccount"
  belongs_to :transfer_status, optional: true, class_name: "BankTransferStatus"
  belongs_to :bank_transaction_type, optional: true
  belongs_to :company
  belongs_to :transfer_mode, optional: true, class_name: 'TransferModeCompanyMapping'


  has_one :payment, as: :reference_resource

  validates :unique_request_number, presence: true

  delegate :amount_value, to: :amount
  delegate :completed?, :processing?, :failed?, :retriable?, :open?, :possible_failure?, :pending_for_processing?, :suspect?, :pending_utr?, :rejected?, to: :transfer_status

  accepts_nested_attributes_for :amount

  scope :processing_transactions, -> {
    where(transfer_status_id: BankTransferStatus.ids_for(:pending_utr, :pending_for_processing, :possible_failure, :suspect))
  }

  scope :completed, -> {
    where(transfer_status_id: BankTransferStatus.id_for(:completed))
  }

  scope :neft, -> {
    where(transfer_type: "RGS")
  }

  scope :imps, -> {
    where(transfer_type: "IFS")
  }

  scope :rtgs, -> {
    where(transfer_type: "RTG")
  }

  def bank_reference_number
    self.utr
  end

  def imps?
    self.txn_type == "IFS"
  end

  def rtgs?
    self.txn_type == "RTG"
  end

  def neft?
    self.txn_type == "RGS"
  end

  def mode
    self.transfer_mode&.mode&.name
  end

end

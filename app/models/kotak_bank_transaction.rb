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
#  bank_response              :text(65535)
#  reversal_status_code       :string(255)
#  reversal_response          :text(65535)
#  reversal_api_counter       :integer          default(0)
#  deleted_at                 :datetime
#  reference_payment_id       :integer
#  bank_error_message         :text(16777215)
#  transfer_mode_id           :integer
#



class KotakBankTransaction < ApplicationRecord
  belongs_to :amount, optional: true
  belongs_to :company
  belongs_to :beneficiary_account, class_name: 'BankAccount'
  belongs_to :transfer_status, class_name: 'BankTransferStatus', optional: true

  has_one :payment, as: :reference_resource

  belongs_to :reference_payment, class_name: "Payment"

  validates :unique_reference_number, presence: true
  # validates :amount_id, presence: true

  delegate :amount_value, to: :amount
  delegate :completed?, :processing?, :failed?, :retriable?, :open?, :possible_failure?, :pending_for_processing?, :suspect?, to: :transfer_status

  accepts_nested_attributes_for :amount

  scope :without_utr, -> { where utr: nil}
  # scope :successful_transactions, -> {where response_status_code: "000" }
  scope :completed, -> {
    where(transfer_status_id: BankTransferStatus.id_for(:completed))
  }

  scope :without_id, -> (id) {
    where.not(id: id)
  }

  scope :status_check_required, -> {
    where transfer_status_id: [
        BankTransferStatus.id_for(:completed),
        BankTransferStatus.id_for(:processing),
        BankTransferStatus.id_for(:pending_utr),
        BankTransferStatus.id_for(:pending)
    ]
  }

  def bank_reference_number
    self.utr
  end
end

############################################################################################
# RESPONSE STATUS CODES
# "000" Success | All Instruments accepted Successfully
# "001" Error | XML Schema validation failed
# "002" Error | Duplicate Message Id |Should ideally reinitiate the transaction
# "003" Error | Invalid Client Code
# "004" Error | Duplicate Instrument Ref Number within Request
# "005" Error | Request Partially Accepted
#         Mostly when multiple payments are sent in one request and few of the requests were accepted
# "006" Error | Instrument rejected due to data validation failure
# "007" Error | Instrument validated successfully
# "008" Error | Invalid Web service consumer IP address
# "009" Error | All Instruments rejected due to data validation failure
# "010" Error | Default user not found for given client
# "011" Error | System encountered severe error. Please contact admin
#
#
# REVERSAL STATUS CODES
# "RE" Rejected | Reinitiate transactions with correct details and new message id
# "AR" Auth Rejected | Reprocess with new message id
# "DF" Insufficient Funds
# "Error-101" Data not found | Wait for 30 mins
# "Error-99" Transaction in Progress
# "CR" Invalid IFS Code | Re initiate payment
# "C" Received | Received -Uploaded at portal successfully. No action to be taken.
# "UP" Transaction Timeout | Manual confirmation to be sought from bank and in case of reject – reinitiate same transaction with fresh message id.
# "U" Paid | - Success with UTR No provided. No action to be taken.
# "CF" Account Doesn't Exist | Incorrect beneficiary account number details. Repush the transaction with correct beneficiary details and new message id
# "R" Rejected | XML/Data Validation failed.You can repush with new message id.

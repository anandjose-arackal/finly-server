# == Schema Information
#
# Table name: yes_bank_transactions
#
#  id                          :integer          not null, primary key
#  unique_request_number       :string(255)
#  transfer_type               :string(255)
#  bank_reference_number       :string(255)
#  unique_response_number      :string(255)
#  amount_id                   :integer
#  beneficiary_bank_account_id :integer
#  company_id                  :integer
#  transfer_status_id          :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  bank_response               :string(255)
#  refunded                    :boolean
#  error_sub_code              :string(255)
#  bank_transaction_type_id    :integer
#  account_name_check          :boolean          default(FALSE)
#  beneficiary_full_name       :string(255)
#  transfer_mode_id            :integer
#  deleted_at                  :datetime
#  bank_error_message          :text(16777215)
#  reference_payment_id        :integer
#

class YesBankTransaction < ApplicationRecord
  belongs_to :amount, optional: true
  belongs_to :company, optional: true
  belongs_to :beneficiary_bank_account, optional: true, class_name: "BankAccount"
  belongs_to :transfer_status, optional: true, class_name: "BankTransferStatus"
  belongs_to :bank_transaction_type, optional: true
  belongs_to :transfer_mode, optional: true, class_name: 'TransferModeCompanyMapping'

  belongs_to :reference_payment, class_name: "Payment", optional: true

  has_one :payment, as: :reference_resource

  validates :bank_reference_number, presence: true, if: :successful?
  validates :unique_request_number, presence: true, if: :through_finly?
  validates :beneficiary_bank_account_id, presence: true, if: :not_account_check?
  validates :transfer_status_id, presence: true
  validates :amount, presence: true
  validates :company, presence: true
  validates :transfer_type, presence: true
  validates :reference_payment, presence: true, unless: :account_name_check?

  accepts_nested_attributes_for :amount

  delegate :amount_value, to: :amount
  delegate :completed?, :processing?, :failed?, :retriable?, :open?, :possible_failure?, to: :transfer_status

  scope :processing_transactions, -> {where transfer_status_id: [BankTransferStatus.id_for(:processing), BankTransferStatus.id_for(:possible_failure)]}

  scope :non_penny_test, -> { where.not(account_name_check: true) }

  scope :without_id, -> (id) {
    where.not(id: id)
  }

  def retriable?
    self.transfer_status_id == BankTransferStatus.id_for(:failed)
  end

  def utr
    self.bank_reference_number
  end

  def mode
    self.transfer_mode&.mode&.name
  end

  private

  def successful?
    [BankTransferStatus.id_for(:completed), BankTransferStatus.id_for(:processing)].include?(self.transfer_status_id)
  end

  def through_finly?
    self.bank_transaction_type_id == BankTransactionType.id_for(:yes_bank)
  end

  def not_account_check?
    !account_name_check
  end

end

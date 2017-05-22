# == Schema Information
#
# Table name: card_transactions
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  card_id                      :integer
#  merchant_name                :string(255)
#  transaction_type             :string(255)
#  post_data                    :text(65535)
#  transaction_amount_id        :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  reference_id                 :string(255)
#  auth_transaction_id          :string(255)
#  transaction_mode             :string(255)
#  itzcash_merchant_key         :string(255)
#  merchant_city                :string(255)
#  response_code                :string(255)
#  serial_id                    :string(255)
#  product_code                 :string(255)
#  transaction_timestamp        :datetime
#  expensed                     :boolean          default(FALSE)
#  error_message                :text(65535)
#  billing_amount_id            :integer
#  is_deleted                   :boolean          default(FALSE)
#  mcc_code                     :string(255)
#  transaction_status           :string(255)
#  api_reference_id             :string(255)
#  cancelled                    :boolean          default(FALSE)
#  cancelled_against_expense_id :integer
#  type_of_details              :string(255)
#

class CardTransaction < ActiveRecord::Base
  include SoftDeletable

  belongs_to :user
  belongs_to :card


  has_one :card_expense, dependent: :destroy

  validates :reference_id, uniqueness: { scope: [:transaction_type] }

  belongs_to :transaction_amount, class_name: 'Amount', dependent: :destroy
  belongs_to :card_amount, class_name: 'Amount', dependent: :destroy
  belongs_to :billing_amount, class_name: 'Amount', dependent: :destroy

  delegate :transaction_amount_value, to: :transaction_amount
  delegate :billing_amount_value, to: :billing_amount
  delegate :card_amount_value, to: :card_amount

  # i.e. a combination of reference ID and transaction type should be unique
  validates_uniqueness_of :reference_id, scope: [:transaction_type]

  accepts_nested_attributes_for :transaction_amount
  accepts_nested_attributes_for :card_amount
  accepts_nested_attributes_for :billing_amount

  default_scope {order(transaction_timestamp: :desc)}

  scope :debits, -> {where transaction_type: 'Debit'}
  scope :credits, -> {where transaction_type: 'Credit'}

  scope :on_date, -> (date) {where('DATE(transaction_timestamp) = ?', date)}

  # scope for timestamp range
  scope :with_transaction_timestamp_range, -> (start_time, end_time) {where('transaction_timestamp >= ? AND transaction_timestamp <= ?', start_time, end_time)}

  scope :atm_withdrawals, -> {where transaction_mode: "ATM"}
  scope :pos_expenses, -> {where transaction_mode: "POS"}
  scope :online_expenses, -> {where('UPPER(transaction_mode) = ?', "ECOM")}
  scope :expensed_transactions, -> {where('UPPER(transaction_mode) IN (?)', ["POS", "ECOM"])}

  def credit?
    self.transaction_type == 'Credit'
  end

  def debit?
    self.transaction_type == 'Debit'
  end

  def atm_withdrawal?
    debit? and transaction_mode == 'ATM'
  end

  def expense?
    debit? and (transaction_mode == 'POS' or transaction_mode == 'ECOM')
  end

end

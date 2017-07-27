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

  # i.e. a combination of reference ID, type of details and transaction type should be unique
  validates_uniqueness_of :reference_id, scope: [:transaction_type, :type_of_details]

  belongs_to :cancelled_against_expense, class_name: 'CardExpense'
  belongs_to :transaction_amount, class_name: 'Amount', dependent: :destroy
  belongs_to :card_amount, class_name: 'Amount', dependent: :destroy
  belongs_to :billing_amount, class_name: 'Amount', dependent: :destroy

  delegate :transaction_amount_value, to: :transaction_amount
  delegate :billing_amount_value, to: :billing_amount
  delegate :card_amount_value, to: :card_amount

  accepts_nested_attributes_for :transaction_amount
  accepts_nested_attributes_for :card_amount
  accepts_nested_attributes_for :billing_amount

  default_scope { where.not(type_of_details: "S").order(transaction_timestamp: :desc) }

  scope :with_id, ->(id) { where id: id }
  scope :debits, -> { where transaction_type: 'Debit' }
  scope :credits, -> { where transaction_type: 'Credit' }

  scope :on_date, -> (date) { where('DATE(transaction_timestamp) = ?', date) }

  scope :joins_billing_amount, -> { joins(:billing_amount) }

  # scope for timestamp range
  scope :with_transaction_timestamp_range, -> (start_time, end_time) { where('transaction_timestamp >= ? AND transaction_timestamp <= ?', start_time, end_time) }


  scope :atm_withdrawals, -> { where transaction_mode: "ATM" }
  scope :with_user, -> (user_id) { where user_id: user_id }
  scope :pos_expenses, -> { where transaction_mode: "POS" }
  scope :online_expenses, -> { where('UPPER(transaction_mode) = ?', "ECOM") }
  scope :expensed_transactions, -> { where('UPPER(transaction_mode) IN (?)', ["POS", "ECOM"]) }
  scope :refunds, -> {
    credits.where.not(cancelled: true).where('UPPER(merchant_name) like ? OR UPPER(merchant_name) like ?', "%Refund%", "%refund%")
  }

  # this will include manual refunds from ItzCash as well as transaction cancellations from any merchant or vendor
  scope :filter_refunds, -> (flag) {
    if ['1', 1].include?(flag)
      credits.where.not(cancelled: true).where('UPPER(merchant_name) like ? OR UPPER(merchant_name) like ?', "%Refund%", "%refund%")
    else
      # do nothing
    end
  }

  scope :filter_atm_withdrawals, -> (flag) {
    if ['1', 1].include?(flag)
      where transaction_mode: "ATM"
    else
      # do nothing
    end
  }

  scope :with_user, ->(user_ids) { where user_id: user_ids }
  scope :with_card, ->(card_ids) { where card_id: card_ids }

  scope :filter_user_id, -> (user_id) {
    where user_id: user_id
  }

  scope :filter_user_search, -> (term){
    user_ids = self.pluck(:user_id)
    matching_user_ids = User.where(id: user_ids).where('first_name LIKE ? OR last_name LIKE ? OR email like ?', "%#{term}%", "%#{term}%", "%#{term}%")
    self.where(user_id: matching_user_ids)
  }

  scope :filter_date, -> (date_from, date_to) {
    unless date_from.blank? && date_to.blank?
      type_val = :transaction_timestamp
      date_from = "1990-01-01" if date_from.blank?
      date_to = DateUtils.local_date if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date if date_to.present?
      transactions = arel_table
      where(transactions[type_val].gteq(date_from).and(transactions[type_val].lteq(date_to)))
    end
  }

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

  def refund?
    if self.merchant_name.include?('Refund') || self.merchant_name.include?('refund')
      if self.transaction_type == 'Credit'
        return true
      end
    end
    false
  end

end

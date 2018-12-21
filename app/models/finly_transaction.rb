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
#  date                        :datetime
#  sequence_number             :integer
#

class FinlyTransaction < ActiveRecord::Base

  include ManageTransactionDetail

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
  has_many :system_messages, as: :messagable, dependent: :destroy
  has_one :transaction_detail

  accepts_nested_attributes_for :amount, :opening_balance, :closing_balance

  delegate :amount_value, to: :amount

  validates :finly_account_id, presence: true
  validates :finly_account_type, presence: true, :inclusion => {:in => AccountManagerUtils.available_accounts(format: :string)}
  validates :transaction_type_id, presence: true
  # validates :transaction_reference_id, presence: true
  validates :company_id, presence: true
  validates :status_id, presence: true
  validates :payment_purpose_id, presence: true
  validates :date, presence: true

  default_scope {order(sequence_number: :desc)}

  delegate :credit?, :debit?, to: :transaction_type

  scope :with_account, -> (account) {where finly_account: account}
  scope :credits, -> {where transaction_type_id: TransactionType.id_for(:credit)}
  scope :debits, -> {where transaction_type_id: TransactionType.id_for(:debit)}
  scope :with_date, -> (date) {where(date: date)}
  scope :with_date_range, -> (start_date, end_date) do
    start_date = start_date.beginning_of_day rescue start_date
    end_date = end_date.end_of_day rescue end_date
    where('finly_transactions.date >= ? AND finly_transactions.date <= ?', start_date, end_date)
  end
  scope :on_or_after_date, -> (date) {where('finly_transactions.date >= ?', date)}
  scope :on_or_before_date, -> (date) {where('finly_transactions.date <= ?', date)}
  scope :before_date, -> (date) {where('finly_transactions.date < ?', date)}
  scope :after_date, -> (date) {where('finly_transactions.date > ?', date)}
  scope :sum_amounts, -> {joins(:amount).sum(:value)}
  scope :success, -> {where status_id: TransactionStatus.id_for(:success)}
  scope :with_reference_id, -> (ref_id) {where transaction_reference_id: ref_id}
  scope :through_finly_dashboard, -> {where payment_purpose_id: PaymentPurpose.ids_for([:advance_outside_finly,
                                                                                        :reimbursement_outside_finly, :advance,
                                                                                        :medical_benefit,
                                                                                        :meal_benefit, :reimbursement, :payroll,
                                                                                        :vendor_payment,
                                                                                        :balance_clearance_outside_finly, :balance_clearance])}
  scope :include_for_export, -> {includes([:transaction_type, :payment_purpose, :amount, :closing_balance, :status,
                                           {payment: [:receiving_user, :initiating_account,
                                                      :receiving_account, {
                                                          original_payment_for_refund: :receiving_user}]},
                                           :associated_transaction])}

  scope :include_for_index, -> { includes(:system_messages) }
  scope :joins_amounts, -> {joins :amount}
  scope :group_by_purpose, -> {group :payment_purpose_id}
  scope :purpose_wise_amount, -> {joins_amounts.group_by_purpose.sum('amounts.value')}
  scope :sort_date_asc, -> {unscope(:order).order(date: :asc, id: :desc)}
  scope :sort_date_desc, -> {unscope(:order).order(date: :desc, id: :desc)}
  scope :limit_to_one, -> {limit 1}

  after_save :set_sequence_number
  after_create :save_transaction_detail

  before_create do
    ref_id = payment&.reference_id
    if ref_id.blank?
      ref_id = Generator.reference_id_for(finly_account, nil, date)
    end
    self.transaction_reference_id = ref_id
  end

  default_scope {order(sequence_number: :desc)}

  delegate :credit?, :debit?, to: :transaction_type

  def set_sequence_number
    if sequence_number.blank?
      self.sequence_number = id * 10
      save
    end
  end

end
# == Schema Information
#
# Table name: payments
#
#  id                 :integer          not null, primary key
#  amount_id          :integer          not null
#  date               :date             not null
#  payment_type_id    :integer          not null
#  initiating_user_id :integer          not null
#  receiving_user_id  :integer          not null
#  note               :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#




class Payment < ActiveRecord::Base
  belongs_to :amount
  belongs_to :payment_type
  belongs_to :initiating_user, class_name: 'User'
  belongs_to :receiving_user, class_name: 'User'
  has_many :reimbursed_reports, class_name: "Report", foreign_key: :reimbursement_id
  has_many :cash_in_hand_settled_reports, class_name: "Report", foreign_key: :cash_in_hand_deduction_id
  has_many :report_tracks
  has_many :money_requests
  has_many :money_request_tracks

  accepts_nested_attributes_for :amount
  delegate :amount_value, to: :amount

  default_scope {order date: :desc, created_at: :desc}

  scope :atm_withdrawals, -> {where payment_type_id: PaymentType.id_for(:atm_withdrawal)}
  scope :advance, -> { where payment_type_id: PaymentType.id_for(:advance) }
  scope :reimbursement, -> { where payment_type_id: PaymentType.id_for(:reimbursement) }
  scope :debt_clearance, -> { where payment_type_id: PaymentType.id_for(:debt_clearance) }
  scope :settlement, -> { where payment_type_id: PaymentType.id_for(:settlement) }
  scope :involving_user, ->(user_id){ where('receiving_user_id = ? OR initiating_user_id = ?', user_id, user_id) }
  scope :received_by_user, ->(user_id) { where receiving_user_id: user_id }
  scope :initiated_by_user, ->(user_id) { where initiating_user_id: user_id }
  scope :transferred_cash_to_user, -> { where payment_type: [PaymentType.id_for(:advance),
                                                             PaymentType.id_for(:reimbursement),
                                                             PaymentType.id_for(:settlement),
                                                             PaymentType.id_for(:atm_withdrawal)] }
  scope :with_amount, -> { joins :amount }
  scope :made_before, ->(date) { where 'date <= ?', date }
  scope :made_after, ->(date) { where 'date >= ?', date }
  scope :with_details, -> { includes :amount, :initiating_user, :receiving_user, :payment_type }
  # Personal are card transactions from own wallet to own card
  # scope :involving_user_credits, ->(user_id){ where.not('initiating_user_id != receiving_user_id AND initiating_user_id = ? AND payment_type_id IN (?)', user_id, [PaymentType.id_for(:credit_from_virtual_account_to_wallet),
  #                                                                                                                      PaymentType.id_for(:credit_from_virtual_account_to_card),
  #                                                                                                                      PaymentType.id_for(:debit_from_wallet_to_virtual_account)]) }
  scope :personal, -> { where "initiating_user_id = receiving_user_id AND (payment_type_id = #{PaymentType.id_for(:credit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:debit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:atm_withdrawal)})" }
  scope :non_personal, -> { where.not "initiating_user_id = receiving_user_id AND (payment_type_id = #{PaymentType.id_for(:credit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:debit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:atm_withdrawal)})" }
  scope :non_settlement, -> {where.not("initiating_user_id = receiving_user_id").where.not(payment_type_id: [PaymentType.id_for(:atm_withdrawal)])}

  # validates :amount_id, presence: true
  validates :date, presence: true
  validates :initiating_user_id, presence: true
  validates :receiving_user_id, presence: true

  def advance?
    self.payment_type_id == PaymentType.id_for(:advance)
  end

  def reimbursement?
    self.payment_type_id == PaymentType.id_for(:reimbursement)
  end

  def debt_clearance?
    self.payment_type_id == PaymentType.id_for(:debt_clearance)
  end

  def settlement?
    self.payment_type_id == PaymentType.id_for(:settlement)
  end

  def total_amount
    self.amount.value rescue nil
  end
end

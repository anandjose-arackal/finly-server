# == Schema Information
#
# Table name: payments
#
#  id                      :integer          not null, primary key
#  amount_id               :integer          not null
#  date                    :date             not null
#  payment_type_id         :integer          not null
#  initiating_user_id      :integer          not null
#  receiving_user_id       :integer          not null
#  note                    :text(65535)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  initiating_account_id   :integer
#  initiating_account_type :string(255)
#  receiving_account_id    :integer
#  receiving_account_type  :string(255)
#


class Payment < ActiveRecord::Base

  class AccountType
    VIRTUAL_ACCOUNT = 'Company'
    WALLET = 'UserWallet'
    CARD = 'Card'
  end

  belongs_to :amount
  belongs_to :payment_type
  belongs_to :initiating_user, class_name: 'User'
  belongs_to :receiving_user, class_name: 'User'
  has_many :reimbursed_reports, class_name: 'Report', foreign_key: :reimbursement_id
  has_many :cash_in_hand_settled_reports, class_name: 'Report', foreign_key: :cash_in_hand_deduction_id
  has_many :report_tracks
  has_many :money_requests
  has_many :money_request_tracks

  accepts_nested_attributes_for :amount
  delegate :amount_value, to: :amount

  default_scope { order date: :desc, created_at: :desc }

  scope :atm_withdrawals, -> { where payment_type_id: PaymentType.id_for(:atm_withdrawal) }
  scope :advance, -> { where payment_type_id: PaymentType.id_for(:add_cash_on_hand) }
  scope :cash_on_hand_additions, -> { where payment_type_id: PaymentType.id_for(:add_cash_on_hand) }
  scope :reimbursement, -> { where payment_type_id: PaymentType.id_for(:reimbursement) }
  scope :debt_clearance, -> { where payment_type_id: PaymentType.id_for(:deduct_cash_on_hand) }
  scope :cash_on_hand_deductions, -> { where payment_type_id: PaymentType.id_for(:deduct_cash_on_hand) }
  scope :settlement, -> { where payment_type_id: PaymentType.id_for(:settlement) }
  scope :involving_user, ->(user_id) { where('receiving_user_id = ? OR initiating_user_id = ?', user_id, user_id) }
  scope :received_by_user, ->(user_id) { where receiving_user_id: user_id }
  scope :initiated_by_user, ->(user_id) { where initiating_user_id: user_id }
  scope :transferred_cash_to_user, -> { where payment_type: [PaymentType.id_for(:add_cash_on_hand),
                                                             PaymentType.id_for(:reimbursement),
                                                             PaymentType.id_for(:settlement),
                                                             PaymentType.id_for(:atm_withdrawal)] }
  scope :with_amount, -> { joins :amount }
  scope :made_before, ->(date) { where 'date <= ?', date }
  scope :made_after, ->(date) { where 'date >= ?', date }
  scope :with_details, -> { includes :amount, :initiating_user, :receiving_user, :payment_type }

  # Personal are card transactions from own wallet to own card

  scope :personal, -> { where('initiating_user_id = receiving_user_id AND (payment_type_id = ? OR (payment_type_id IN (?) AND initiating_account_type IN (?) AND receiving_account_type IN (?)))',
                              PaymentType.id_for(:atm_withdrawal), [PaymentType.id_for(:credit), PaymentType.id_for(:debit)], [Payment::AccountType::WALLET, Payment::AccountType::CARD],
                              [Payment::AccountType::WALLET, Payment::AccountType::CARD]) }
  scope :non_personal, -> { where.not('initiating_user_id = receiving_user_id AND (payment_type_id = ? OR (payment_type_id IN (?) AND initiating_account_type IN (?) AND receiving_account_type IN (?)))',
                                      PaymentType.id_for(:atm_withdrawal), [PaymentType.id_for(:credit), PaymentType.id_for(:debit)], [Payment::AccountType::WALLET, Payment::AccountType::CARD],
                                      [Payment::AccountType::WALLET, Payment::AccountType::CARD]) }
  scope :non_settlement, -> { where.not('initiating_user_id = receiving_user_id AND payment_type_id IN (?) AND initiating_account_type IN (?) AND receiving_account_type IN (?)',
                                        [PaymentType.id_for(:credit), PaymentType.id_for(:debit), [Payment::AccountType::WALLET, Payment::AccountType::CARD],
                                         [Payment::AccountType::WALLET, Payment::AccountType::CARD]]).where.not(payment_type_id: [PaymentType.id_for(:atm_withdrawal)]) }

  # scope :personal, -> { where "initiating_user_id = receiving_user_id AND (payment_type_id = #{PaymentType.id_for(:credit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:debit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:atm_withdrawal)})" }
  # scope :non_personal, -> { where.not "initiating_user_id = receiving_user_id AND (payment_type_id = #{PaymentType.id_for(:credit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:debit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:atm_withdrawal)})" }
  # scope :non_settlement, -> { where.not("initiating_user_id = receiving_user_id AND payment_type_id IN (?)", [PaymentType.id_for(:credit_from_wallet_to_card),
  #                                                                                                             PaymentType.id_for(:debit_from_wallet_to_card),
  #                                                                                                             PaymentType.id_for(:credit_from_card_to_wallet),
  #                                                                                                             PaymentType.id_for(:debit_from_card_to_wallet)]).where.not(payment_type_id: [PaymentType.id_for(:atm_withdrawal)]) }
  scope :with_date, -> (date) { where(date: date) }
  scope :with_date_range, -> (start_date, end_date) { where('date >= ? AND date <= ?', start_date, end_date) }

  scope :credit_to_card, -> { where(payment_type_id: [PaymentType.id_for(:credit)], receiving_account_type: Payment::AccountType::CARD) }
  scope :credit_to_wallet, -> { where(payment_type_id: [PaymentType.id_for(:credit)], receiving_account_type: Payment::AccountType::WALLET) }
  scope :debit_from_card, -> { where(payment_type_id: [PaymentType.id_for(:debit)], receiving_account_type: Payment::AccountType::CARD) }
  scope :debit_from_wallet, -> { where(payment_type_id: [PaymentType.id_for(:debit)], receiving_account_type: Payment::AccountType::WALLET) }
  scope :credit_from_virtual_account, -> { where(payment_type_id: [PaymentType.id_for(:credit)], initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT) }
  scope :debit_to_virtual_account, -> { where(payment_type_id: [PaymentType.id_for(:debit)], initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT) }
  scope :debit_to_card, -> { where(payment_type_id: [PaymentType.id_for(:debit)], initiating_account_type: Payment::AccountType::CARD) }
  scope :debit_to_wallet, -> { where(payment_type_id: [PaymentType.id_for(:debit)], initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT) }
  scope :credit_from_card, -> { where(payment_type_id: [PaymentType.id_for(:credit)], initiating_account_type: Payment::AccountType::CARD) }
  scope :credit_from_wallet, -> { where(payment_type_id: [PaymentType.id_for(:credit)], initiating_account_type: Payment::AccountType::WALLET) }

  scope :credit_from_virtual_account_to_wallet, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::WALLET }
  scope :credit_from_virtual_account_to_card, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::CARD }
  scope :credit_from_card_to_wallet, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::WALLET }
  scope :credit_from_wallet_to_wallet, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::WALLET }
  scope :credit_from_wallet_to_card, -> { where payment_type_id: PaymentType.id_for(:credit_from_wallet_to_card) }
  scope :credit_from_card_to_card, -> { where payment_type_id: PaymentType.id_for(:credit_from_card_to_card) }
  scope :debit_from_wallet_to_card, -> { where payment_type_id: PaymentType.id_for(:debit_from_wallet_to_card) }
  scope :debit_from_wallet_to_wallet, -> { where payment_type_id: PaymentType.id_for(:debit_from_wallet_to_wallet) }
  scope :debit_from_wallet_to_virtual_account, -> { where payment_type_id: PaymentType.id_for(:debit_from_wallet_to_virtual_account) }
  scope :debit_from_card_to_virtual_account, -> { where payment_type_id: PaymentType.id_for(:debit_from_card_to_virtual_account) }
  scope :debit_from_card_to_wallet, -> { where payment_type_id: PaymentType.id_for(:debit_from_card_to_wallet) }
  scope :debit_from_card_to_card, -> { where payment_type_id: PaymentType.id_for(:debit_from_card_to_card) }


  scope :personal_transfer_to_card, -> { personal.where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card), PaymentType.id_for(:debit_from_wallet_to_card)]) }
  scope :non_personal_transfer_to_card, -> { non_personal.where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card), PaymentType.id_for(:debit_from_wallet_to_card)]) }

  scope :cash_additions_to_employee, -> { where(payment_type_id: [PaymentType.id_for(:add_cash_on_hand), PaymentType.id_for(:reimbursement)]) }
  scope :cash_deductions_from_employee, -> { where(payment_type_id: [PaymentType.id_for(:deduct_cash_on_hand)]) }

  # validates :amount_id, presence: true
  validates :date, presence: true
  validates :initiating_user_id, presence: true
  validates :receiving_user_id, presence: true

  def advance?
    self.payment_type_id == PaymentType.id_for(:add_cash_on_hand)
  end

  def reimbursement?
    self.payment_type_id == PaymentType.id_for(:reimbursement)
  end

  def debt_clearance?
    self.payment_type_id == PaymentType.id_for(:deduct_cash_on_hand)
  end

  def settlement?
    self.payment_type_id == PaymentType.id_for(:settlement)
  end

  def total_amount
    self.amount.value rescue nil
  end
end

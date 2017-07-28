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
#  payment_order_id        :integer
#  payment_status_id       :integer          not null
#





class Payment < ActiveRecord::Base

  class Payment::AccountType
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

  belongs_to :payment_order
  belongs_to :payment_status

  belongs_to :initiating_account, polymorphic: true
  belongs_to :receiving_account, polymorphic: true

  has_many :system_messages, as: :messagable, dependent: :destroy

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
                                        [PaymentType.id_for(:credit), PaymentType.id_for(:debit)], [Payment::AccountType::WALLET, Payment::AccountType::CARD],
                                        [Payment::AccountType::WALLET, Payment::AccountType::CARD]).where.not(payment_type_id: [PaymentType.id_for(:atm_withdrawal)]) }

  # scope :personal, -> { where "initiating_user_id = receiving_user_id AND (payment_type_id = #{PaymentType.id_for(:credit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:debit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:atm_withdrawal)})" }
  # scope :non_personal, -> { where.not "initiating_user_id = receiving_user_id AND (payment_type_id = #{PaymentType.id_for(:credit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:debit_from_wallet_to_card)} OR payment_type_id = #{PaymentType.id_for(:atm_withdrawal)})" }
  # scope :non_settlement, -> { where.not("initiating_user_id = receiving_user_id AND payment_type_id IN (?)", [PaymentType.id_for(:credit_from_wallet_to_card),
  #                                                                                                             PaymentType.id_for(:debit_from_wallet_to_card),
  #                                                                                                             PaymentType.id_for(:credit_from_card_to_wallet),
  #                                                                                                             PaymentType.id_for(:debit_from_card_to_wallet)]).where.not(payment_type_id: [PaymentType.id_for(:atm_withdrawal)]) }
  scope :with_date, -> (date) { where(date: date) }
  scope :with_date_range, -> (start_date, end_date) { where('date >= ? AND date <= ?', start_date, end_date) }
  scope :with_payment_type_id, -> (payment_type_id) { where payment_type_id: payment_type_id }

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
  scope :credit_from_wallet_to_card, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::CARD }
  scope :credit_from_card_to_card, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::CARD }
  scope :debit_from_wallet_to_card, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::WALLET }
  scope :debit_from_wallet_to_wallet, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::WALLET }
  scope :debit_from_wallet_to_virtual_account, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::WALLET }
  scope :debit_from_card_to_virtual_account, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::CARD }
  scope :debit_from_card_to_wallet, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::CARD }
  scope :debit_from_card_to_card, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::CARD }

  scope :transfer_to_card, -> { where('(payment_type_id = ? AND receiving_account_type = ?) OR (payment_type_id = ? AND initiating_account_type = ?)',
                                      PaymentType.id_for(:credit), Payment::AccountType::CARD, PaymentType.id_for(:debit), Payment::AccountType::CARD) }
  scope :personal_transfer_to_card, -> { personal.transfer_to_card }
  scope :non_personal_transfer_to_card, -> { non_personal.transfer_to_card }

  # { personal.where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card), PaymentType.id_for(:debit_from_wallet_to_card)]) }
  # scope :non_personal_transfer_to_card, -> { non_personal.where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card), PaymentType.id_for(:debit_from_wallet_to_card)]) }

  scope :cash_additions_to_employee, -> { where(payment_type_id: [PaymentType.id_for(:add_cash_on_hand), PaymentType.id_for(:reimbursement)]) }
  scope :cash_deductions_from_employee, -> { where(payment_type_id: [PaymentType.id_for(:deduct_cash_on_hand)]) }

  # validates :amount_id, presence: true
  validates :date, presence: true
  validates :initiating_user_id, presence: true
  validates :receiving_user_id, presence: true
  validate :initiating_account_presence
  validate :receiving_account_presence

  delegate :completed?, :failed?, :pending?, :in_progress?, :scheduled?, to: :payment_status

  def initiating_account_type_name
    name = ""
    unless self.initiating_account_type == 'Company'
      name += "#{self.initiating_user.name}'s"
    end
    if [PaymentType.id_for(:add_cash_on_hand), PaymentType.id_for(:deduct_cash_on_hand),
        PaymentType.id_for(:reimbursement), PaymentType.id_for(:settlement),
        PaymentType.id_for(:reimbursement_outside_finly)].include?(self.payment_type_id)
      return nil
    end

    case self.initiating_account_type
      when 'UserWallet'
        name += " Finly Money"
      when 'Company'
        name += " Company Credits"
      when 'Card'
        name += " #{self.initiating_account.card_program.name.humanize} Card"
    end
    name
  end

  def receiving_account_type_name
    name = ""

    unless self.receiving_account_type == 'Company'
      name += "#{self.receiving_user.name}'s"
    end

    if [PaymentType.id_for(:add_cash_on_hand), PaymentType.id_for(:deduct_cash_on_hand),
        PaymentType.id_for(:reimbursement), PaymentType.id_for(:settlement)].include?(self.payment_type_id)
      name += " Cash on Hand"
      return name
    end

    if [PaymentType.id_for(:reimbursement_outside_finly)].include?(self.payment_type_id)
      name = 'Settled Outside Finly'
      return name
    end

    case self.receiving_account_type
      when 'UserWallet'
        name += " Finly Money"
      when 'Company'
        name += " Company Credits"
      when 'Card'
        name += " #{self.receiving_account.card_program.name.humanize} Card"
    end
    name
  end

  def credit?
    self.payment_type_id == PaymentType.id_for(:credit)
  end

  def debit?
    self.payment_type_id == PaymentType.id_for(:debit)
  end

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

  def clear_system_messages
    if system_messages.present?
      system_messages.destroy_all
    end
  end

  private

  def initiating_account_presence
    unless [PaymentType.id_for(:add_cash_on_hand), PaymentType.id_for(:deduct_cash_on_hand),
            PaymentType.id_for(:reimbursement), PaymentType.id_for(:settlement),
            PaymentType.id_for(:reimbursement_outside_finly)].include?(self.payment_type_id)
      if initiating_account_id.blank? || receiving_account_type.blank?
        errors.add(:initiating_account, "cannot be blank")
      end
    end
  end

  def receiving_account_presence
    unless [PaymentType.id_for(:add_cash_on_hand), PaymentType.id_for(:deduct_cash_on_hand),
            PaymentType.id_for(:reimbursement), PaymentType.id_for(:settlement),
            PaymentType.id_for(:reimbursement_outside_finly)].include?(self.payment_type_id)
      if receiving_account_id.blank? || receiving_account_type.blank?
        errors.add(:receiving_account, "cannot be blank")
      end
    end
  end

end

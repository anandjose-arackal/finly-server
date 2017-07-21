# == Schema Information
#
# Table name: cards
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  ending_number            :string(255)      not null
#  proxy                    :string(255)      not null
#  card_type_id             :integer
#  description              :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  company_id               :integer          not null
#  disabled_by_role_id      :integer
#  disabled_by_user_id      :integer
#  active                   :boolean
#  disable_note             :text(65535)
#  card_balance_id          :integer
#  card_program_id          :integer
#  card_eligibility_id      :integer
#  admin_unblockable        :boolean          default(TRUE)
#  itz_cash_card_program_id :integer
#  card_status_id           :integer          not null
#  is_deleted               :boolean          default(FALSE)
#

class Card < ActiveRecord::Base
  include SoftDeletable

  belongs_to :card_type
  belongs_to :user
  belongs_to :company
  belongs_to :disabled_by_role, class_name: 'UserRole'
  belongs_to :disabled_by_user, class_name: 'User'
  belongs_to :card_program
  belongs_to :itz_cash_card_program
  belongs_to :card_status
  has_many :transactions, class_name: 'CardTransaction'
  has_many :initiating_payments, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account

  has_one :card_restriction

  has_many :card_balance_history
  has_many :card_assign_requests

  belongs_to :card_balance, class_name: 'Amount'
  belongs_to :card_eligibility, class_name: 'Amount'

  accepts_nested_attributes_for :card_program
  accepts_nested_attributes_for :card_balance
  accepts_nested_attributes_for :card_eligibility

  default_scope {}

  scope :with_id, -> (id) { where id: id }
  scope :with_user, -> (user_id) { where user_id: user_id }
  scope :unassigned, -> { where user_id: nil }
  scope :active, -> { where active: true }
  scope :expense_cards, -> { where card_program_id: CardProgram.id_for(:expense) }
  scope :manager_viewable_transactions, -> { where card_program_id: CardProgram.all.with_manager_view_transactions.pluck(:id) }
  scope :with_card_program, ->(id) { where card_program_id: id }
  scope :creditable_cards, -> { with_card_program(CardProgram.all.with_manager_credit) }
  scope :with_non_personal_fund_transfer, -> { with_card_program(CardProgram.all.with_non_personal_fund_transfer) }
  scope :reimbursable_cards, -> { with_card_program(CardProgram.all.with_reimbursement) }
  scope :meal_cards, -> {where card_program_id: CardProgram.id_for(:meal)}

  scope :expense_cards_only, -> { where card_program_id: CardProgram.id_for(:expense) }
  scope :reimbursement_cards_only, -> { where card_program_id: CardProgram.id_for(:reimbursement) }

  scope :filter_search, -> (term) {
    if term.present?
      where('proxy like ?', "%#{term}%")
    else
      # do nothing
    end
  }

  delegate :card_balance_value, to: :card_balance
  delegate :card_program_name, to: :card_program
  delegate :itz_cash_card_program_name, to: :itz_cash_card_program

  validates :proxy, uniqueness: true, format: {with: /\A[S]\d{11}\z/}, length: {is: 12}
  validates :ending_number, presence: true
  # validates :card_program_id, presence: true
  validates :company_id, presence: true
  # validates :itz_cash_card_program_id, presence: true
  validate :card_program_with_user

  after_create do
    user = self.user

    result = ItzCash::AccountDetails.(user, {card: self, unassigned: true})

    # marking the card by default as either active or inactive
    if result.success?
      case result.status_code
        when 'A'
          if result.suspended_status == 'N'
            self.update(active: true)
          else
            self.update(active: false)
          end
        else
          self.update(active: false)
      end
    end

    balance_amount = result.balance rescue 0

    self.card_balance_history.build(amount_attributes: {value: balance_amount, currency_id: 1}, timestamp: DateUtils.local_date_time).save

    # building card restriction
    self.build_card_restriction(channel_atm: true, channel_ecom_pos: true, card_limits_attributes: [{period_id: 1, limit_type_id: ChannelType.id_for(:ecom_pos)},
                                                                                                    {period_id: 2, limit_type_id: ChannelType.id_for(:ecom_pos)},
                                                                                                    {period_id: 3, limit_type_id: ChannelType.id_for(:ecom_pos)},
                                                                                                    {period_id: 1, limit_type_id: ChannelType.id_for(:atm)},
                                                                                                    {period_id: 2, limit_type_id: ChannelType.id_for(:atm)},
                                                                                                    {period_id: 3, limit_type_id: ChannelType.id_for(:atm)}]).save
  end


  def unblockable?
    if self.active
      false
    else
      if self.disabled_by_user_id
        if self.disabled_by_user_id == self.user_id
          return true
        end
        return false
      else
        return true
      end
    end
  end

  def product_code
    self.itz_cash_card_program.product_code
  end


  # attr_accessor :balance, :available_card_eligibility
  def balance
    if card_balance.blank?
      ItzCash::AccountDetails.(user, card: self)
    end
    self.card_balance.value
  end

  def available_card_eligibility
    if card_eligibility.blank?
      ItzCash::AccountDetails.(user, card: self)
    end
    self.card_eligibility.value
  end

  def serial_id
    self.proxy
  end

  def inactive?
    !self.active
  end

  def active?
    self.active
  end

  def unassigned?
    self.card_status_id == CardStatus.id_for(:unassigned) and self.user_id.blank?
  end

  def assigned?
    return (not [CardStatus.id_for(:unassigned), CardStatus.id_for(:assign_requested)].include?(self.card_status_id))
  end

  def expense_card?
    if self.card_program_id == CardProgram.id_for(:expense)
      return true
    end
    false
  end

  def reimbursement_card?
    if self.card_program_id == CardProgram.id_for(:reimbursement)
      return true
    end
    false
  end


  private

  def card_program_with_user
    if self.user_id.present?
      if self.card_program_id.blank?
        errors.add(:card, "must have an associated card program")
      end
    end
  end


end

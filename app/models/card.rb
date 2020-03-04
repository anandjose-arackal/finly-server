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
#  hotlisted                :boolean          default(FALSE)
#  card_processor_status    :string(255)
#  replaced_card_id         :integer
#  deleted_at               :datetime
#

class Card < ApplicationRecord
  include Accountable
  include SoftDeletable

  belongs_to :card_type, optional: true
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :disabled_by_role, optional: true, class_name: 'UserRole'
  belongs_to :disabled_by_user, optional: true, class_name: 'User'
  belongs_to :card_program, optional: true
  belongs_to :itz_cash_card_program, optional: true
  belongs_to :card_status, optional: true
  belongs_to :replaced_card, optional: true, class_name: "Card"
  has_many :transactions, class_name: 'CardTransaction'
  has_many :initiating_payments, as: :initiating_account
  has_many :initiating_payment_trails, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account
  has_many :receiving_payment_trails, as: :receiving_account
  has_many :finly_transactions, as: :finly_account

  has_one :card_restriction

  has_many :card_balance_history
  has_many :card_assign_requests

  belongs_to :card_balance, optional: true, class_name: 'Amount'
  belongs_to :card_eligibility, optional: true, class_name: 'Amount'

  accepts_nested_attributes_for :card_program
  accepts_nested_attributes_for :card_balance
  accepts_nested_attributes_for :card_eligibility

  default_scope {where hotlisted: false}

  scope :with_id, -> (id) {where id: id}
  scope :with_user, -> (user_id) {where user_id: user_id}
  scope :with_user_id, -> (user_id) { where user_id: user_id}
  scope :with_company, -> (company_id) {where company_id: company_id}
  scope :unassigned, -> {where user_id: nil}
  scope :active, -> {where active: true}
  scope :expense_cards, -> {where card_program_id: CardProgram.id_for(:expense)}
  scope :reimbursement_cards, -> {where card_program_id: CardProgram.id_for(:reimbursement)}
  scope :manager_viewable_transactions, -> {where card_program_id: CardProgram.all.with_manager_view_transactions.pluck(:id)}
  scope :with_card_program, ->(id) {where card_program_id: id}
  scope :creditable_cards, -> {with_card_program(CardProgram.all.with_manager_credit)}
  scope :with_non_personal_fund_transfer, -> {with_card_program(CardProgram.all.with_non_personal_fund_transfer)}
  scope :reimbursable_cards, -> {with_card_program(CardProgram.all.with_reimbursement)}
  scope :meal_cards, -> {where card_program_id: CardProgram.id_for(:meal)}
  scope :payroll_cards, -> {where card_program_id: CardProgram.id_for(:payroll)}
  scope :sum_balance, -> {joins(:card_balance).sum('amounts.value')}
  scope :non_hotlisted, -> {
    # if applied == '1'
    where hotlisted: false
    # end
  }
  scope :pluck_proxy, -> {pluck :proxy}
  scope :include_hotlisted, -> {unscope(where: :hotlisted)}

  scope :expense_cards_only, -> {where card_program_id: CardProgram.id_for(:expense)}
  scope :reimbursement_cards_only, -> {where card_program_id: CardProgram.id_for(:reimbursement)}
  scope :with_proxy, -> (proxy) {where proxy: proxy}
  scope :with_id_or_proxy, -> (id) {where 'id = ? OR proxy = ?', id, id}

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
  delegate :manager_view_balance, to: :card_program


  validates :proxy, uniqueness: true, format: {with: /\A[S]\d{11}\z/}, length: {is: 12}
  validates :ending_number, presence: true
  # validates :card_program_id, presence: true
  validates :company_id, presence: true
  # validates :itz_cash_card_program_id, presence: true
  validate :card_program_with_user
  validates :card_status_id, presence: true

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
    self.build_card_restriction(channel_atm: true,
                                channel_ecom_pos: true,
                                card_limits_attributes: [{period_id: 1, limit_type_id: ChannelType.id_for(:ecom_pos)},
                                                         {period_id: 2, limit_type_id: ChannelType.id_for(:ecom_pos)},
                                                         {period_id: 3, limit_type_id: ChannelType.id_for(:ecom_pos)},
                                                         {period_id: 1, limit_type_id: ChannelType.id_for(:atm)},
                                                         {period_id: 2, limit_type_id: ChannelType.id_for(:atm)},
                                                         {period_id: 3, limit_type_id: ChannelType.id_for(:atm)}]).save

    reload
    if card_balance_id.nil? and card_balance.nil?
      balance_amount = Amount.create(value: 0, currency_id: Currency.id_for(:INR))
      self.update(card_balance: balance_amount)
    end
    if card_eligibility_id.nil? and card_eligibility.nil?
      eligibility_amount = Amount.create(value: 0, currency_id: Currency.id_for(:INR))
      self.update(card_eligibility: eligibility_amount)
    end
  end

  # def proxy
  #   if self.replaced_with.present?
  #     self.replaced_with.proxy
  #   end
  #   super
  # end

  def api_proxy
    if self.replaced_card.present?
      self.replaced_card.proxy
    else
      self.proxy
    end
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
    (self.card_balance&.value || 0)
  end

  def available_card_eligibility
    if card_eligibility.blank?
      ItzCash::AccountDetails.(user, card: self)
    end
    (self.card_eligibility&.value || 0)
  end

  # always use serial_id in APIs
  def serial_id
    api_proxy
  end

  def inactive?
    !self.active
  end

  def active?
    self.active and self.card_processor_status == Constants::CARD_PROCESSOR_STATUS[:active]
  end

  def temporary_block?
    !self.active and self.card_processor_status == Constants::CARD_PROCESSOR_STATUS[:active]
  end

  def locked?
    [Constants::CARD_PROCESSOR_STATUS[:locked], Constants::CARD_PROCESSOR_STATUS[:blocked]].include?(self.card_processor_status)
  end

  def unassigned?
    self.card_status_id == CardStatus.id_for(:unassigned) and self.user_id.blank?
  end

  def assign_requested?
    self.card_status_id == CardStatus.id_for(:assign_requested)
  end

  def upgraded?
    self.card_status_id == CardStatus.id_for(:upgraded)
  end

  def atm_allowed?
    upgraded? and card_restriction.channel_atm
  end

  def max_eligibility
    upgraded? ? 100000 : 20000
  end

  def assigned?
    if Rails.env.production?
      (not [CardStatus.id_for(:unassigned), CardStatus.id_for(:assign_requested)].include?(self.card_status_id) and user_id.present?)
    else
      true
    end
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

  def suspend_status
    status = self.card_processor_status
    if status == Constants::CARD_PROCESSOR_STATUS[:active] and !self.active
      status = 'Blocked'
    elsif status != Constants::CARD_PROCESSOR_STATUS[:active]
      status = 'Locked'
    end
    status
  end

  def as_json(options = {})
    {
        id: id,
        user: user,
        proxy: proxy,
        description: description,
        active: active,
        hotlisted: hotlisted,
        locked: locked?,
        card_status: card_status,
        card_balance: card_balance,
        card_program: card_program,
        card_eligibility: card_eligibility,
        disabled: {
            disabled_by_user: disabled_by_user,
            disabled_by_role: disabled_by_role,
            disable_note: disable_note
        }
    }
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

# == Schema Information
#
# Table name: cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  ending_number       :string(255)      not null
#  proxy               :string(255)      not null
#  card_type_id        :integer
#  description         :text(65535)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :integer
#  disabled_by_role_id :integer
#  disabled_by_user_id :integer
#  active              :boolean
#  disable_note        :text(65535)
#  product_code        :string(255)      not null
#  card_balance_id     :integer
#  card_program_id     :integer          not null
#  card_eligibility_id :integer
#

class Card < ActiveRecord::Base
  belongs_to :card_type
  belongs_to :user
  belongs_to :company
  belongs_to :disabled_by_role, class_name: 'UserRole'
  belongs_to :disabled_by_user, class_name: 'User'
  belongs_to :card_program
  has_many :transactions, class_name: 'CardTransaction'
  has_many :initiating_payments, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account


  has_one :card_restriction, dependent: :destroy

  has_many :card_balance_history, dependent: :destroy

  belongs_to :card_balance, class_name: 'Amount'
  belongs_to :card_eligibility, class_name: 'Amount'

  accepts_nested_attributes_for :card_program
  accepts_nested_attributes_for :card_balance
  accepts_nested_attributes_for :card_eligibility

  scope :with_id, ->(id) { where id: id }
  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :unassigned, -> { where user_id: nil }
  scope :active, -> { where active: true }
  scope :expense_cards, -> { where card_program_id: CardProgram.id_for(:expense) }
  scope :with_card_program, ->(id) { where card_program_id: id }
  scope :creditable_cards, -> { with_card_program(CardProgram.all.with_manager_credit) }
  scope :reimbursable_cards, -> { with_card_program(CardProgram.all.with_reimbursement) }

  delegate :card_balance_value, to: :card_balance

  validates :proxy, uniqueness: true, format: {with: /[S]\d{11}/}, length: {is: 12}
  validates :user_id, presence: true
  validates :ending_number, presence: true
  validates :card_program_id, presence: true

  after_create do
    user = self.user

    result = ItzCash::AccountDetails.(user, card_id: self.id)
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

  # after_create do
  #   user = self.user
  #   result = ItzCash::AccountDetails.(user, card_id: self.id)
  #   balance_amount = result.balance rescue 0
  #   eligibility_amount = result.available_card_eligibility rescue 0
  #   unless self.card_balance
  #     balance = Amount.create!(value: balance_amount, currency_id: Currency.first.id)
  #     self.update_attributes(card_balance_id: balance.id)
  #   end
  #   unless self.card_eligibility
  #     balance = Amount.create!(value: eligibility_amount, currency_id: Currency.first.id)
  #     self.update_attributes(card_eligibility_id: balance.id)
  #   end
  #
  #   self.card_balance_history.build(amount_attributes: {value: balance_amount, currency_id: 1}, timestamp: DateUtils.local_date_time).save
  #
  #   # building card restriction
  #   self.build_card_restriction(channel_atm: true, channel_ecom_pos: true, card_limits_attributes: [{period_id: 1, limit_type_id: ChannelType.id_for(:ecom_pos)},
  #                                                                                                   {period_id: 2, limit_type_id: ChannelType.id_for(:ecom_pos)},
  #                                                                                                   {period_id: 3, limit_type_id: ChannelType.id_for(:ecom_pos)},
  #                                                                                                   {period_id: 1, limit_type_id: ChannelType.id_for(:atm)},
  #                                                                                                   {period_id: 2, limit_type_id: ChannelType.id_for(:atm)},
  #                                                                                                   {period_id: 3, limit_type_id: ChannelType.id_for(:atm)}]).save
  # end


  # attr_accessor :balance, :available_card_eligibility

  def unblockable?
    if self.disabled_by_user_id != self.user_id
      return false
    end
    true
  end

  def balance
    self.card_balance.value
  end

  def available_card_eligibility
    self.card_eligibility.value
  end

  def serial_id
    self.proxy
  end

  private

end

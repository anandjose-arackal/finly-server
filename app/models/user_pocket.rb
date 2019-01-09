# == Schema Information
#
# Table name: user_pockets
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  balance_id                 :integer
#  user_pocket_type_id        :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  account_code               :string(255)
#  atm_withdrawal_pocket      :boolean          default(FALSE)
#  user_id                    :integer
#  base_currency_id           :integer
#  company_pocket_template_id :integer
#

class UserPocket < ActiveRecord::Base

  include Accountable

  belongs_to :user_pocket_type
  belongs_to :balance, class_name: "Amount"
  belongs_to :user
  belongs_to :base_currency, class_name: "Currency"
  belongs_to :company_pocket_template

  # adding associations to payment and Finly Transactions
  has_many :initiating_payments, as: :initiating_account, class_name: "Payment", dependent: :destroy
  has_many :receiving_payments, as: :receiving_account, class_name: "Payment", dependent: :destroy
  has_many :finly_transactions, as: :finly_account, dependent: :destroy

  validates :user, presence: true
  validates :user_pocket_type, presence: true
  # validates :base_currency_id, presence: true

  accepts_nested_attributes_for :balance

  delegate :balance_value, to: :balance
  delegate :cash_pocket?, :credit_card_pocket?, :bank_transfer_pocket?, :card_transfer_pocket?, :reimbursement?, :paid_by_company?, to: :user_pocket_type

  scope :with_id, -> (ids) { where id: ids}
  scope :cash_pockets_only, -> {
    where user_pocket_type_id: UserPocketType.id_for(:cash)
  }
  scope :credit_card_pockets_only, -> {
    where user_pocket_type_id: UserPocketType.id_for(:credit_card)
  }
  scope :cash_and_credit_cards, -> {
    where user_pocket_type_id: [UserPocketType.id_for(:cash), UserPocketType.id_for(:credit_card)]
  }
  scope :non_bank_card_transfer_pockets, -> {
    where user_pocket_type_id: [UserPocketType.id_for(:cash), UserPocketType.id_for(:credit_card),
                                UserPocketType.id_for(:reimbursement), UserPocketType.id_for(:paid_by_company)]
  }
  scope :reimbursement_pocket_only,->{
    where user_pocket_type_id: UserPocketType.id_for(:reimbursement)
  }
  scope :paid_by_company_pocket_only,->{
    where user_pocket_type_id: UserPocketType.id_for(:paid_by_company)
  }
  scope :card_transfer_pockets_only, -> {
    where user_pocket_type_id: UserPocketType.id_for(:card_transfer)
  }
  scope :bank_transfer_pockets_only, -> {
    where user_pocket_type_id: UserPocketType.id_for(:bank_transfer)
  }

  scope :atm_withdrawal_pockets, -> {
    where atm_withdrawal_pocket: true
  }
  scope :with_user_id, -> (user_ids) {
    where user_id: user_ids
  }

  scope :include_details, -> {includes :user_pocket_type, :base_currency, {balance: [:currency]}}

  def blocked_amount_for_pending_payments(excluded_payment_order_id = nil)
    initiating_account = self
    payment_ids = PaymentOrder.find_by(id: excluded_payment_order_id)&.payments&.pluck(:id)
    Payment.scheduled.with_initiating_account_type("UserPocket").with_initiating_account_id(initiating_account.id).without_id(payment_ids).joins(:amount).sum(:value)
  end

  def can_claim_reimbursement
    reimbursement?
  end

end
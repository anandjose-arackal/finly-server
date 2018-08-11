# == Schema Information
#
# Table name: user_pockets
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  balance_id            :integer
#  user_pocket_type_id   :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_code          :string(255)
#  atm_withdrawal_pocket :boolean          default(FALSE)
#  user_id               :integer
#

class UserPocket < ActiveRecord::Base

  belongs_to :user_pocket_type
  belongs_to :balance, class_name: "Amount"
  belongs_to :user

  validates :user, presence: true
  validates :user_pocket_type, presence: true

  accepts_nested_attributes_for :balance

  delegate :balance_value, to: :balance

  scope :cash_pockets_only, -> {
    where user_pocket_type_id: UserPocketType.id_for(:cash)
  }
  scope :card_transfer_pockets_only, -> {
    where user_pocket_type_id: UserPocketType.id_for(:card_transfer)
  }
  scope :bank_transfer_pockets_only, -> {
    where user_pocket_type_id: UserPocketType.id_for(:bank_transfer)
  }

  def blocked_amount_for_pending_payments(excluded_payment_order_id = nil)
    initiating_account = self
    payment_ids = PaymentOrder.find_by(id: excluded_payment_order_id)&.payments&.pluck(:id)
    Payment.scheduled.with_initiating_account_type("UserPocket").with_initiating_account_id(initiating_account.id).without_id(payment_ids).joins(:amount).sum(:value)
  end

end
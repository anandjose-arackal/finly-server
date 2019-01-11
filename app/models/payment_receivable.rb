# == Schema Information
#
# Table name: payment_receivables
#
#  id                           :integer          not null, primary key
#  customer_id                  :integer
#  amount_id                    :integer
#  purpose                      :text(65535)
#  expire_by                    :date
#  company_id                   :integer
#  initiating_user_id           :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  email                        :string(255)
#  payment_receivable_status_id :integer
#  payment_id                   :integer
#

class PaymentReceivable < ApplicationRecord

  belongs_to :customer, optional: true
  belongs_to :amount, optional: true
  belongs_to :company, optional: true
  belongs_to :initiating_user, optional: true, class_name: "User"
  belongs_to :payment_receivable_status, optional: true

  has_one :virtual_bank_account, as: :parent, dependent: :destroy
  has_one :payment

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :customer

  delegate :amount_value, to: :amount, allow_nil: true

  def active?
    self.payment_receivable_status_id == PaymentReceivableStatus.id_for(:active)
  end

  def inactive?
    self.payment_receivable_status_id == PaymentReceivableStatus.id_for(:inactive)
  end

  def received?
    self.payment_receivable_status_id == PaymentReceivableStatus.id_for(:received)
  end
end

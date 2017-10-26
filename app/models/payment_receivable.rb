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
#

class PaymentReceivable < ActiveRecord::Base

  belongs_to :customer
  belongs_to :amount
  belongs_to :company
  belongs_to :initiating_user, class_name: "User"
  belongs_to :payment_receivable_status

  has_one :virtual_bank_account, as: :parent, dependent: :destroy

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :customer
end

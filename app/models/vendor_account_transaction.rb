# == Schema Information
#
# Table name: vendor_account_transactions
#
#  id                  :integer          not null, primary key
#  vendor_account_id   :integer
#  transaction_type_id :integer
#  amount_id           :integer
#  payment_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class VendorAccountTransaction < ApplicationRecord
  belongs_to :vendor_account, optional: true
  belongs_to :amount, optional: true
  belongs_to :payment, optional: true
  belongs_to :transaction_type, optional: true

  accepts_nested_attributes_for :amount

  delegate :credit, :debit, to: :transaction_type

  validates :vendor_account_id, presence: true
  validates :transaction_type_id, presence: true
  validates :amount_id, presence: true

end

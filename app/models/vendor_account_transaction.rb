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

class VendorAccountTransaction < ActiveRecord::Base
  belongs_to :vendor_account
  belongs_to :amount
  belongs_to :payment
  belongs_to :transaction_type

  accepts_nested_attributes_for :amount

  delegate :credit, :debit, to: :transaction_type

  validates :vendor_account_id, presence: true
  validates :transaction_type_id, presence: true
  validates :amount_id, presence: true

end

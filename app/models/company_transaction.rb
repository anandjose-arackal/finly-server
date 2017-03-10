# == Schema Information
#
# Table name: company_transactions
#
#  id                    :integer          not null, primary key
#  company_id            :integer          not null
#  request_id            :string(255)      not null
#  merchant_name         :string(255)      not null
#  transaction_date      :datetime         not null
#  transaction_amount_id :integer          not null
#  transaction_type      :string(255)      not null
#  transaction_id        :string(255)      not null
#  balance_amount_id     :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  transaction_mode      :string(255)
#  merchant_type_key     :string(255)
#

class CompanyTransaction < ActiveRecord::Base
  belongs_to :company
  belongs_to :transaction_amount, class_name: 'Amount'
  belongs_to :balance_amount, class_name: 'Amount'

  validates :company, presence: true
  validates :transaction_id, uniqueness: true, presence: true
  validates :merchant_name, presence: true
  validates :transaction_date, presence: true
  validates :transaction_amount, presence: true
  validates :transaction_type, presence: true
  validates :transaction_id, presence: true
  validates :balance_amount, presence: true

  delegate :transaction_amount_value, to: :transaction_amount

  accepts_nested_attributes_for :balance_amount
  accepts_nested_attributes_for :transaction_amount

  scope :with_date_range, -> (start_date, end_date) { where('transaction_date >= ? AND transaction_date <= ?', start_date, end_date) }
  scope :with_date, -> (date) {where('DATE(transaction_date) = ?', date)}
  scope :sort_date, -> (type){ order transaction_date: type}

  scope :manual_fund_credits, -> {where(transaction_mode: "MANUAL FUND CREDIT")}


end

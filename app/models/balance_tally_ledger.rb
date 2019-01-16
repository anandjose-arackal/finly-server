# == Schema Information
#
# Table name: balance_tally_ledgers
#
#  id                        :integer          not null, primary key
#  date                      :date
#  api_balance_id            :integer
#  finly_database_balance_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class BalanceTallyLedger < ActiveRecord::Base

  belongs_to :api_balance, class_name: "Amount"
  belongs_to :finly_database_balance, class_name: "Amount"
  belongs_to :calculated_balance, class_name: "Amount"

  validates :date, presence: true
  validates :api_balance, presence: true
  validates :finly_database_balance, presence: true

  accepts_nested_attributes_for :api_balance, :finly_database_balance, :calculated_balance
end

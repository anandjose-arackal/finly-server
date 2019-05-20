# == Schema Information
#
# Table name: bank_account_masters
#
#  id             :bigint           not null, primary key
#  account_number :string(255)
#  ifsc           :string(255)
#  account_name   :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class BankAccountMaster < ApplicationRecord

  validates :account_number, presence: true
  validates :ifsc, presence: true
  validates :account_name, presence: true

  def as_json
    {
      id: id,
      account_name: account_name,
      account_number: account_number,
      ifsc: ifsc
    }
  end
end

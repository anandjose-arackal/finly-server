# == Schema Information
#
# Table name: bank_accounts
#
#  id                 :integer          not null, primary key
#  yes_bank_vendor_id :integer
#  account_number     :string(255)
#  ifsc               :string(255)
#  name               :string(255)
#  address_1          :string(255)
#  address_2          :string(255)
#  address_3          :string(255)
#  pin_code           :string(255)
#  country            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_owner_id   :integer
#  account_owner_type :string(255)
#  company_id         :integer
#

class BankAccount < ActiveRecord::Base
  belongs_to :account_owner, polymorphic: true

  has_many :receiving_payments, as: :receiving_account
  has_many :finly_transactions, as: :finly_account

  validates :account_number, presence: true
  validates :ifsc, presence: true

  accepts_nested_attributes_for :account_owner

  delegate :name, to: :account_owner

  scope :with_account_owner, -> (user_ids, vendor_ids) {
    where('(account_owner_type = ? AND account_owner_id IN (?)) OR (account_owner_type - ? AND account_owner_id IN (?)', "User", user_ids, "YesBankVendor", vendor_ids)
  }

  scope :with_owner_ids, -> (type, ids) {
    case type
      when 1, '1'
        where(account_owner_type: "User").where(id: ids)
      when 2, '2'
        where(account_owner_type: "YesBankVendor").where(id: ids)
    end
  }

  scope :filter_owner_type, -> (owner_type) {
    if owner_type == '1'
      where account_owner_type: "User"
    elsif owner_type == '2'
      where account_owner_type: "YesBankVendor"
    else
      # do nothing?
    end
  }

  scope :beneficiary_type, -> (owner_type) {
    if owner_type == '1'
      where account_owner_type: "User"
    elsif owner_type == '2'
      where account_owner_type: "YesBankVendor"
    else
      # do nothing?
    end
  }

  after_create do
    self.update(company_id: self.account_owner.company_id)
  end
end

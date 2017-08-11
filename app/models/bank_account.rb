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
#

class BankAccount < ActiveRecord::Base
  belongs_to :account_owner, polymorphic: true

  has_many :receiving_payments, as: :receiving_account

  validates :account_number, presence: true
  validates :ifsc, presence: true

  accepts_nested_attributes_for :account_owner

  delegate :name, to: :account_owner
end

# == Schema Information
#
# Table name: customers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  email         :string(255)
#  mobile_number :string(255)
#  description   :text(65535)
#  company_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  gst           :string(255)
#  pan           :string(255)
#  created_by_id :integer
#  active        :boolean          default(TRUE)
#

class Customer < ActiveRecord::Base

  belongs_to :company
  belongs_to :created_by, class_name: "User"

  has_many :addresses, as: :parent
  has_many :customer_attachments
  has_many :virtual_bank_accounts
  has_many :outward_invoices

  has_one :customer_account

  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :virtual_bank_accounts
  accepts_nested_attributes_for :customer_attachments

  validates :name, presence: true
  # validates :created_by, presence: true

  scope :active, -> { where active: true }
  scope :inactive, -> { where active: false }

  scope :filter_search, -> (term) {
    where('name like ? OR email like ? OR mobile_number like ? or description like ? OR gst like ?', "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  }


  scope :filter_created_at, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}

  scope :search_by_virtual_accounts, -> (account_number) {
    joins(:virtual_bank_accounts).where('virtual_bank_accounts.account_number like ?', "%#{account_number}%")
  }

  scope :with_virtual_accounts, -> (account_numbers) {
    joins(:virtual_bank_accounts).where(account_number: account_numbers)
  }

  # will most likely be a checkbox on the front end
  scope :virtual_accounts_presence, -> (presence) {
    if StringUtils.to_bool(presence)
      cust_ids = pluck(:id)
      ids = VirtualBankAccount.with_customer_id(cust_ids).pluck(:customer_id)
      where(id: ids)
    end
  }

end
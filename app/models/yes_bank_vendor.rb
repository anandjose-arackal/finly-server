# == Schema Information
#
# Table name: yes_bank_vendors
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  company_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  email          :string(255)
#  mobile_number  :string(255)
#  authorized     :boolean
#  description    :text(65535)
#  is_deleted     :boolean          default(FALSE)
#  pan            :string(255)
#  tin            :string(255)
#  gst            :string(255)
#  gst_registered :boolean
#  state          :string(255)
#  state_code     :string(255)
#

class YesBankVendor < ActiveRecord::Base
  belongs_to :company
  belongs_to :state_code, class_name: "GstStateCode"
  belongs_to :created_by, class_name: "User"

  has_many :bank_accounts, as: :account_owner, dependent: :destroy
  has_many :receiving_payments, as: :receiving_user, class_name: "Payment"
  has_many :vendor_attachments

  accepts_nested_attributes_for :bank_accounts
  accepts_nested_attributes_for :vendor_attachments, allow_destroy: true

  scope :including_bank_accounts, -> {joins(:bank_accounts)}
  scope :non_deleted, -> { where is_deleted: [false, nil]}
  scope :authorized, -> { where authorized: true}

  scope :filter_search, -> (term) {
    vendor_ids = where("name like ? OR email like ? OR mobile_number like ? OR description like ?", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)
    bank_account_ids = BankAccount.where("account_number like ? OR ifsc like ? OR name like ?", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)
    vendor_ids += BankAccount.where(account_owner_type: "YesBankVendor").where(id: bank_account_ids).pluck(:account_owner_id)
    where(id: vendor_ids)
  }

end
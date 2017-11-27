# == Schema Information
#
# Table name: yes_bank_vendors
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  company_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  email         :string(255)
#  mobile_number :string(255)
#  authorized    :boolean
#  description   :string(255)
#  is_deleted    :boolean          default(FALSE)
#

class YesBankVendor < ActiveRecord::Base
  belongs_to :company

  has_many :bank_accounts, as: :account_owner, dependent: :destroy
  has_many :receiving_payments, as: :receiving_user, class_name: 'Payment'
  has_many :vendor_attachments

  accepts_nested_attributes_for :bank_accounts
  accepts_nested_attributes_for :vendor_attachments, allow_destroy: true

  scope :including_bank_accounts, -> {joins(:bank_accounts)}
  scope :non_deleted, -> { where is_deleted: [false, nil]}
  scope :authorized, -> { where authorized: true}

  def as_json(options={})
    {
        name: name,
        email: email,
        mobile_number: mobile_number,
        description: description
    }
  end

end

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
#

class Customer < ActiveRecord::Base

  belongs_to :company
  belongs_to :created_by, class_name: "User"

  has_many :addresses, as: :parent
  has_many :customer_attachments
  has_many :virtual_bank_accounts

  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :virtual_bank_accounts

  validates :name, presence: true
  # validates :created_by, presence: true
end

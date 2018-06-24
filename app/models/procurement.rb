# == Schema Information
#
# Table name: procurements
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  procurement_track_id  :integer
#  procurement_status_id :integer
#  vendor_id             :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer
#  company_id            :integer
#  note                  :text(65535)
#

class Procurement < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :procurement_track
  belongs_to :procurement_status
  belongs_to :vendor, class_name: "YesBankVendor"

  has_one :purchase_order
  has_many :inward_documents
  has_many :invoices
  has_many :bill_of_supplies
  has_many :delivery_challans
  has_many :e_way_bills

  default_scope { order(updated_at: :desc) }
end

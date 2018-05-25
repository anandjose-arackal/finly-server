# == Schema Information
#
# Table name: inward_documents
#
#  id                          :integer          not null, primary key
#  company_id                  :integer
#  procurement_id              :integer
#  vendor_id                   :integer
#  doc_number                  :string(255)
#  override_doc_number         :string(255)
#  prefix                      :string(255)
#  delivery_date               :date
#  transported_name            :string(255)
#  transporter_document_number :string(255)
#  vehicle_number              :string(255)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class InwardDocument < ActiveRecord::Base
  belongs_to :procurement
  belongs_to :user
  belongs_to :vendor, class_name: "YesBankVendor"
  has_many :items, class_name: "InwardDocumentItem"

  accepts_nested_attributes_for :items
end

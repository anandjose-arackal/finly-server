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
#  is_deleted                  :boolean          default(FALSE), not null
#  user_id                     :integer
#

class InwardDocument < ActiveRecord::Base
  include SoftDeletable
  belongs_to :procurement
  belongs_to :user
  belongs_to :company
  belongs_to :vendor, class_name: "YesBankVendor"
  has_many :items, class_name: "InwardDocumentItem"

  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable

  has_many :trails, as: :parent

  accepts_nested_attributes_for :items


  scope :document_number_generated_in_finly, -> { where override_invoice_number: [false, nil] }

  def items_shipped
    total = 0
    shipped = 0
    self.items.each do |item|
      total += item.quantity
      shipped += item.accepted
    end

    "#{shipped}/#{total} delivered"
  end

  def procurement_index_details
    {
        id: id,
        document_number: self.doc_number,
        amount: self.items_shipped,
        document_owner: self.user&.name,
        document_type: self.class.name
    }
  end
end

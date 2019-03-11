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
#  deleted_at                  :datetime
#

class InwardDocument < ApplicationRecord
  include SoftDeletable
  belongs_to :procurement, optional: true
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :vendor, optional: true, class_name: "YesBankVendor"
  has_many :items, class_name: "InwardDocumentItem"

  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable

  has_many :trails, as: :parent

  accepts_nested_attributes_for :items


  scope :document_number_generated_in_finly, -> { where override_invoice_number: [false, nil] }

  scope :with_doc_number, -> (doc_number) {where doc_number: doc_number}
  scope :filter_doc_number, -> (doc_number) {where('inward_documents.doc_number LIKE ?', "%#{doc_number}%")}
  scope :filter_delivery_date, -> (delivery_date) { where "delivery_date = ?", delivery_date}

  def items_shipped
    total = 0
    shipped = 0
    self.items.each do |item|
      total += item.quantity.to_f
      shipped += item.accepted.to_f
    end

    "#{shipped}/#{total} delivered"
  end

  def procurement_index_details
    {
        id: id,
        document_number: self.doc_number,
        amount: self.items_shipped,
        document_owner: self.user&.name,
        document_type: self.class.name,
        delivery_date: self.delivery_date

    }
  end

  def self.roles
    {'1'=> 'admin', '12'=> 'purchase_order_initiator', '13'=> 'purchase_order_reviewer', '15'=> 'invoice_initiator', '16'=> 'invoice_reviewer', '14'=> 'goods_receiver'}
  end

end

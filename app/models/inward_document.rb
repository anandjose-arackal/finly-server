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
#  grn_number                  :string(255)
#

class InwardDocument < ApplicationRecord
  include SoftDeletable,
          Transitionable
  include Sequenced::ActsAsSequenced

  acts_as_sequenced column: :grn_number, purpose: :grn, editable: false, prefix: 'GRN-'

  belongs_to :procurement, optional: true
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  belongs_to :vendor, optional: true, class_name: "YesBankVendor"
  has_many :items, class_name: "InwardDocumentItem", dependent: :destroy

  has_many :attachments, class_name: 'ProcurementAttachment', as: :procurement_document
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable

  has_many :trails, as: :parent

  accepts_nested_attributes_for :items


  scope :document_number_generated_in_finly, -> { where override_invoice_number: [false, nil] }

  scope :with_doc_number, -> (doc_number) {where doc_number: doc_number}
  scope :filter_doc_number, -> (doc_number) {where('inward_documents.doc_number LIKE ?', "%#{doc_number}%")}
  scope :filter_delivery_date, -> (delivery_date) { where 'delivery_date = ?', delivery_date}
  scope :filter_received_date, -> (received_date) { where 'updated_at = ?', received_date}

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
        delivery_date: self.delivery_date&.strftime("%d-%m-%Y"),
        received_date: self.updated_at&.strftime("%d-%m-%Y")

    }
  end

  def self.roles
    [:goods_receiver]
  end

  def validate_if_owner?(user)
    self.user_id == user.id
  end

  def validate_if_manager?(user)
    user.is_goods_receiver?
  end

  def validate_if_admin?(user)
    user.vp_admin_or_auditor?
  end

end

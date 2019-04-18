# == Schema Information
#
# Table name: purchase_request_items
#
#  id                           :bigint(8)        not null, primary key
#  purchase_request_id          :integer
#  item_id                      :integer
#  vendor_id                    :integer
#  delivery_location_id         :integer
#  purpose                      :text(65535)
#  quantity                     :decimal(20, 5)
#  per_unit_estimated_amount_id :integer
#  estimated_amount_id          :integer
#  required_by_date             :date
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  approved                     :boolean
#  status_id                    :integer
#  purchase_order_id            :integer
#  rejected                     :boolean
#  unit_of_measurement          :string(255)
#  reject_note                  :string(255)
#

    # table_name => purchase_request_items
    # 
    #                     :id => :integer,
    #    :purchase_request_id => :integer,
    # :inventory_line_item_id => :integer,
    #              :vendor_id => :integer,
    #   :delivery_location_id => :integer,
    #                :purpose => :text,
    #               :quantity => :integer,
    #         :unit_amount_id => :integer,
    #    :estimated_amount_id => :integer,
    #          :delivery_date => :date,
    #             :created_at => :datetime,
    #             :updated_at => :datetime


class PurchaseRequestItem < ApplicationRecord
  # include Transitionable

  belongs_to :purchase_request, optional: true
  belongs_to :item, optional: true
  belongs_to :per_unit_estimated_amount, optional: true, class_name: "Amount", dependent: :destroy
  belongs_to :estimated_amount, optional: true, class_name: "Amount", dependent: :destroy
  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'
  belongs_to :status, optional: true, class_name: 'PurchaseRequestItemStatus', foreign_key: :status_id
  belongs_to :purchase_order, optional: true
  has_one :attachment, inverse_of: :resource, foreign_key: :resource_id, as: :resource, dependent: :destroy
  has_many :trails, as: :parent

  validates :item, :quantity, :per_unit_estimated_amount, :required_by_date, :delivery_location, :purpose, presence: true

  accepts_nested_attributes_for :per_unit_estimated_amount, :attachment, allow_destroy: true

  after_create :add_attachment

  scope :with_ids, -> (ids) { where id: ids }
  scope :with_id, -> (id) { where id: id }
  scope :non_rejected, -> { where rejected: [nil, false] }
  scope :rejected, -> { where rejected: true }
  scope :issued_from_inventory, -> { where status_id: PurchaseRequestItemStatus.id_for(:issued_from_inventory)}
  scope :po_created, -> { where status_id: PurchaseRequestItemStatus.id_for(:po_created) }
  scope :approved, -> { where status_id: PurchaseRequestItemStatus.id_for(:approved) }

  scope :item_id, -> (id) {
    where item_id: id
  }

  scope :vendor_id, -> (id) {
    where vendor_id: id
  }

  scope :date, -> (date) {
    date = Date.parse(date) rescue Date.today
    where('DATE(required_by_date) = ?', date)
  }

  scope :location_id, -> (id) {
    where delivery_location_id: id
  }

  scope :order_number, -> (order_number) {
    joins(:purchase_request).where('purchase_requests.order_number = ?', order_number)
  }


  def update_estimated_amount
    quantity = self.quantity
    per_unit_price = self.per_unit_estimated_amount&.value
    if quantity.present? && per_unit_price.present?
      amount = Amount.create(currency_id: 1, value: quantity*per_unit_price)
      self.estimated_amount_id = amount.id
      self.save
    end
  end

  def add_attachment
    # Can be put into AR transaction
    params = RequestStore[:params]
    line_item_attributes = params.dig(:purchase_request, :purchase_request_items_attributes)
    if line_item_attributes.present?
      line_item_attributes.each do |position, line_item|
        attachment_id = line_item.dig(:attachment_attributes, :id) rescue nil
        if attachment_id.present?
          attachment = Attachment.find_by_id attachment_id
          attachment.resource_id = self.id
          attachment.save
        end
      end
    end
  end

end

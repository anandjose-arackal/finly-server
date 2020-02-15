# == Schema Information
#
# Table name: purchase_request_items
#
#  id                           :bigint           not null, primary key
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
#  department_id                :integer
#  cost_center_id               :integer
#  category_id                  :integer
#  hsn_sac                      :string(255)
#  rate_contract_item_id        :integer
#  uuid                         :string(36)
#  deleted_at                   :datetime
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
  include FieldCustomizer::CustomizableValidation
  # include Transitionable

  field_customization_key :purchase_request_item
  customizable_validate :purpose, presence: true, scope: [:purchase_request, :company]

  belongs_to :purchase_request, optional: true
  belongs_to :item, optional: true
  belongs_to :per_unit_estimated_amount, optional: true, class_name: "Amount", dependent: :destroy
  belongs_to :estimated_amount, optional: true, class_name: "Amount", dependent: :destroy
  belongs_to :delivery_location, optional: true, class_name: 'BranchLocation'
  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'
  belongs_to :status, optional: true, class_name: 'PurchaseRequestItemStatus', foreign_key: :status_id
  belongs_to :purchase_order, optional: true
  belongs_to :department, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :category, optional: true
  belongs_to :rate_contract_item, optional: true, class_name: 'RateContractLineItem'
  has_one :attachment, inverse_of: :resource, foreign_key: :resource_id, as: :resource, dependent: :destroy
  has_one :purchase_order_item
  has_many :trails, as: :parent

  has_many :custom_fields, as: :parent, dependent: :destroy


  validates :item, :quantity, :per_unit_estimated_amount, :required_by_date, :delivery_location, presence: true
  validates_presence_of :cost_center, :department, if: :cost_allocation_items?

  accepts_nested_attributes_for :per_unit_estimated_amount, :attachment, allow_destroy: true

  after_create :add_attachment

  scope :with_ids, -> (ids) { where id: ids }
  scope :with_id, -> (id) { where id: id }
  scope :non_rejected, -> { where rejected: [nil, false] }
  scope :rejected, -> { where rejected: true }
  scope :issued_from_inventory, -> { where status_id: PurchaseRequestItemStatus.id_for(:issued_from_inventory)}
  scope :po_created, -> { where status_id: PurchaseRequestItemStatus.id_for(:po_created) }
  scope :approved, -> { where status_id: [PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved)] }

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

  scope :search_item_name, -> (item_name) {
    joins(:item).where('items.description LIKE ?', "%#{item_name}%")
  }

  scope :search_order_number, -> (order_number) {
    joins(:purchase_request).where('purchase_requests.order_number LIKE ?', "%#{order_number}%")
  }

  scope :search_preferred_vendor, -> (vendor_name) {
    joins(:vendor).where('yes_bank_vendors.name LIKE ?', "%#{vendor_name}%")
  }

  scope :search_delivery_location, -> (location_name) {
    joins(purchase_request: :location).where('branch_locations.name LIKE ?', "%#{location_name}%")
  }

  scope :filter_policy_id, -> (policy_id) {
    if policy_id.present?
      joins(:purchase_request).where('purchase_requests.policy_id = ?', policy_id)
    end
  }

  scope :filter_location_id, -> (location_id) {
    joins(:purchase_request).where('purchase_requests.location_id = ?', location_id)
  }

  scope :filter_department_id, -> (department_id) {
    joins(:purchase_request).where('purchase_requests.location_id = ?', department_id)
  }

  scope :filter_year, -> (year) {
    if year.blank?
      year = Date.today.year
    end
    where('extract(year from created_at) = ?', year)
  }

  scope :filter_month, -> (month) {
    if month.blank?
      month = Date.today.month
    end
    where('extract(month from created_at) = ?', month)
  }

  scope :filter_by_date_range, -> (from, to) {
    if from.present? || to.present?
      from = Date.parse('01-01-1990') if from.blank?
      to = Date.today if to.blank?
      from = Date.parse(from) unless from.is_a?(Date)
      to = Date.parse(to) unless to.is_a?(Date)
      where('DATE(created_at) >= ? && DATE(created_at) <= ?', from, to)
    end
  }

  scope :role_based_filter, -> (boolean) {
    if StringUtils.to_bool(boolean)
      user = RequestStore.store[:current_user]
      approved_purchase_requests = user.company.purchase_requests.role_based_filter(true)
      if approved_purchase_requests.present?
        approved_item_ids = approved_purchase_requests.joins(:purchase_request_items).pluck('purchase_request_items.id')
        with_ids(approved_item_ids)
      end
    end
  }


  def update_estimated_amount
    quantity = self.quantity
    per_unit_price = self.per_unit_estimated_amount&.value
    if quantity.present? && per_unit_price.present?
      amount = Amount.create(currency_id: 1, value: quantity*per_unit_price)
      self.estimated_amount_id = amount.id
      if self.save
        self.purchase_request.update_total_amount
      end
    end
  end

  def add_attachment
    # Can be put into AR transaction
    params = RequestStore[:params]
    line_item_attributes = params.dig(:purchase_request, :purchase_request_items_attributes) rescue nil
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

  def cost_allocation_items?
    self.purchase_request.cost_allocation_items
  end

end

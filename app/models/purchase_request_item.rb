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
#  deleted_at                   :datetime
#  company_id                   :integer
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
  attr_accessor :skip_callback, :po_creator, :po_number, :reject_item
  include FieldCustomizer::CustomizableValidation
  include LiquidDroppable
  include Exposures::Model::Exposable
  include FormsHelper
  include MathUtil
  # include Transitionable

  field_customization_key :purchase_request_item
  customizable_validate :purpose, presence: true, scope: [:purchase_request, :company]

  belongs_to :company, optional: true
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


  alias_attribute :items_department_id, :department_id
  alias_attribute :items_cost_center_id, :cost_center_id

  has_many :custom_fields, as: :parent, dependent: :destroy

  has_paper_trail(
      meta: {
          parent_document_type: "Purchase Request"
      }
  )

  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy

  validates :item, :quantity, :per_unit_estimated_amount, :required_by_date, :delivery_location, presence: true, unless: :parent_forms_enabled
  validates_presence_of :cost_center, :department, if: :cost_allocation_items?

  accepts_nested_attributes_for :per_unit_estimated_amount, :attachment, allow_destroy: true

  after_create :add_attachment
  after_save :sync_amounts, unless: :skip_callback
  after_save :set_currency_for_amount, unless: :skip_callback

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
    false if parent_forms_enabled
  end

  def retrieve_value(entity)  
    send("#{entity.entity_key.gsub('_id', '')}")&.name rescue send(entity.entity_key)
  end  

  def parent_forms_enabled
    self.purchase_request.forms_enabled
  end

  def po_creator
    self.purchase_order&.user&.name
  end

  def po_number
    {
      label: self.purchase_order&.po_number,
      url: "procure_purchase_orders/#{self.purchase_order&.id}/params={\"procurement_id\": \"#{self.purchase_order&.procurement.id}\"}"
    }
  end

  def reject_item
    rejected ? "Reject" : "Approve"
  end

  private

  def sync_amounts
    if parent_forms_enabled
      sync_to_old_structure
    end
  end

  def sync_to_old_structure
    self.skip_callback = true
    base_currency_id = purchase_request.get_base_currency.id
    amounts_attributes_map.each do |key, value|
      amount_value = self.send(key)
      amount_attr = self.send("#{value}_id")
      if amount_attr.present?
        Amount.find_by(id: amount_attr).update(value: amount_value, currency_id: base_currency_id)
      else
        amount_id = Amount.create(value: amount_value, currency_id: base_currency_id).id
        self.send("#{value}_id=", amount_id)
      end
    end

    unless purchase_request.cost_allocation_items
      self.department_id = purchase_request&.department_id
      self.cost_center_id = purchase_request&.cost_center_id
    end

    self.save
  end

  def amounts_attributes_map
    {  
      rate: 'per_unit_estimated_amount',
      item_gross_amount: 'estimated_amount' 
    }
  end


  def budget_trail_entry
    # if PurchaseOrderStatus.ids_for([:approved, :auto_approved, :sent_to_vendor, :closed]).include?(self.purchase_order&.purchase_order_status_id)
    #   calling the trail saving processor method that will take care of saving the budget trail
    # BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(self)
    # else
    #   BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(self)
    # end
    if self.purchase_request.rejected? || self.purchase_request.cancelled?
      BudgetManager::BudgetsCalculator::Calculate::PurchaseRequestItemsBudgetsProcessor.new.destroy_trail(self)
    else
      BudgetManager::BudgetsCalculator::Calculate::PurchaseRequestItemsBudgetsProcessor.new.save_trail(self)
    end
  end

  def budget_trail_destroy
    BudgetManager::BudgetsCalculator::Calculate::PurchaseRequestItemsBudgetsProcessor.new.destroy_trail(self)
  end

  def set_currency_for_amount
    amount_attr = [:per_unit_estimated_amount, :estimated_amount]

    amount_attr.each do |amount_attribute|
      amount_attr_id = self.send("#{amount_attribute}_id")
      if amount_attr_id.present?
        Amount.find_by(id: amount_attr_id).update(currency_id: self.purchase_request.get_base_currency.id)
      end
    end
    self.skip_callback = true
    self.save
  end


end

# frozen_string_literal: true
# == Schema Information
#
# Table name: items
#
#  id                   :integer          not null, primary key
#  tax                  :decimal(20, 10)
#  discount             :decimal(20, 10)
#  hsn_sac              :string(255)
#  company_id           :integer
#  sku                  :string(255)
#  rate                 :decimal(20, 10)
#  description          :text(65535)
#  category_id          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  note                 :text(65535)
#  tax_rate_id          :integer
#  is_deleted           :boolean          default(FALSE), not null
#  item_code            :string(255)
#  account              :string(255)
#  supply_item_type_id  :integer
#  deleted_at           :datetime
#  product_type_id      :integer          default(1)
#  item_number          :string(255)
#  unit_of_measurement  :string(255)
#  user_id              :integer
#  active               :boolean          default(TRUE)
#  item_expense_type_id :integer
#  tds_applicable       :boolean          default(TRUE)
#

class Item < ApplicationRecord
  include SoftDeletable
  include Sequenced::ActsAsSequenced
  include MathUtil
  include EventProducer


  event_channel 'item'

  acts_as_sequenced column: :item_number, purpose: :item_master, min_length: 8, editable: false, prefix: -> (record) { record.goods? ? "G" : "S" }

  default_scope {unscope(where: :deleted_at)}
  belongs_to :company, optional: true
  belongs_to :category, optional: true
  belongs_to :tax_rate, optional: true
  belongs_to :supply_item_type, optional: true
  belongs_to :product_type, optional: true#, class_name: "ProductType", foreign_key: :product_type_id
  belongs_to :user, optional: true
  belongs_to :created_by, optional: true, class_name: 'User', foreign_key: :user_id
  belongs_to :item_expense_type, optional: true

  has_many :rate_contract_line_items, foreign_key: :item_id
  # LineItem and Branch Location Mapping
  has_many :branch_locations
  has_many :inventory_line_item_location_mappings, through: :branch_locations
  has_many :artifacts, as: :resource, dependent: :destroy
  has_many :custom_fields, as: :parent, dependent: :destroy
  # validates :rate, presence: true
  validates :description, presence: true
  # validates :hsn_sac, format: {with: /\A(\d{6}|\d{8})\Z/}, allow_blank: true
  validates :hsn_sac, numericality: {only_integer: true}, length: {minimum: 4, maximum: 8}, allow_blank: true

  accepts_nested_attributes_for :artifacts, allow_destroy: true

  scope :with_category_id, -> (id) { where category_id: id }
  scope :search_term, -> (term) {
    where("description like ? OR sku like ? OR note like ? OR hsn_sac like ? OR item_number like ?", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  }
  scope :filter_search, -> (term) {
    where("description like ? OR sku like ? OR note like ? OR hsn_sac like ? OR item_number like ?", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  }
  scope :filter_category_id, -> (category_id) { where category_id: category_id }

  # Filter though supply item type
  scope :filter_item_type, -> (type_id) do
    if type_id.is_a?(Array)
      if type_id.map(&:to_i).include?(SupplyItemType.id_for(:po_item))
        new_type_id = type_id + [nil] + [SupplyItemType.id_for(:po_non_po_item)]
        where supply_item_type_id: new_type_id
      elsif type_id.map(&:to_i).include?(SupplyItemType.id_for(:non_po_item))
        new_type_id = type_id + [SupplyItemType.id_for(:po_non_po_item)]
        where supply_item_type_id: new_type_id
      end
    end
  end

  scope :with_id, -> (id) { where id: id }

  scope :filter_active, -> (active) {
    active = StringUtils.to_bool(active)
    where active: active
  }

  scope :filter_ids, ->(ids) {
    where id: ids
  }

  scope :includes_for_export, -> {includes(:category,:item_expense_type,:product_type, :supply_item_type, :tax_rate)}

  delegate :po_item?, :non_po_item?, to: :supply_item_type

  def goods?
    self.product_type_id == ProductType.id_for(:goods)
  end

  def service?
    self.product_type_id == ProductType.id_for(:service)
  end


  after_save :budget_trail_entry

  def as_json(options={})
    {
        id: id,
        item_number: item_number,
        unit_of_measurement: unit_of_measurement,
        hsn_sac: hsn_sac,
        category_name: category&.name,
        category_id: category_id,
        category_gl_code: category&.gl_code,
        rate: rate,
        description: description,
        discount: discount,
        sku: sku,
        tax_amount: self.tax_amount,
        tax_rate_id: tax_rate_id,
        tax: tax,
        account: account,
        item_code: item_code,
        gl_code: self&.category&.gl_code,
        supply_item_type_id: supply_item_type_id,
        item_type: supply_item_type.as_json,
        product_type: product_type_id,
        product_type_label: product_type_label,
        rate_contract_vendors: rate_contract_vendors,
        preferred_vendors: rate_contract_vendors,
        user: user,
        active: active,
        item_expense_type_id: item_expense_type_id,
        item_expense_type_name: item_expense_type&.name,
        tds_applicable: tds_applicable,
        tds_applicable_label: (tds_applicable ? "yes" : "no"),
        custom_description: get_custom_description,
        custom_fields: self.custom_fields

    }
  end

  def tax_amount
    self.tax_rate&.rate
  end

  # def validate_if_owner?(user)
  #   self.creator_id == user.id
  # end

  def validate_if_manager?(user)
    user.is_item_master_manager?
  end

  def validate_if_admin?(user)
    user.vp_admin_or_auditor?
  end

  def generate_sequential_id?
    # if the user is sending the vendor_id already and does
    # not want default, do NOT generate one
    if self.item_number.present?
      return false
    end
    self.product_type_id.present?
  end

  def rate_contract_vendors
    rate_contract_line_items.joins(:rate_contract).map{|line_item| { vendor_id: line_item.rate_contract.vendor.id, vendor_name: line_item.rate_contract.vendor.display_name, rate:  precision_value(line_item&.amount&.value), rate_contract_item_id: line_item.id}}
  end

  def get_custom_description
    item_number.present? ? "#{description} (#{item_number})" : description
  end

  private

  def budget_trail_entry
    purchase_order_items = PurchaseOrderItem.with_inventory_line_item(self.id)
    purchase_order_items.each do |item|
      BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(item)
    end
  end

  def product_type_label
    label = ""
    case product_type_id
    when ProductType.id_for(:goods)
      label = "goods"
    when ProductType.id_for(:service)
      label = "service"
    end
    label
  end

end

# == Schema Information
#
# Table name: purchase_order_items
#
#  id                       :integer          not null, primary key
#  purchase_order_id        :integer
#  inventory_line_item_id   :integer
#  product_id               :string(255)
#  description              :text(16777215)
#  hsn_sac                  :string(255)
#  quantity                 :decimal(20, 5)
#  rate                     :decimal(20, 5)
#  tax                      :decimal(20, 5)
#  tds                      :decimal(20, 5)
#  discount                 :decimal(20, 5)
#  tax_amount_id            :integer
#  tds_amount_id            :integer
#  discount_amount_id       :integer
#  total_amount_id          :integer
#  delivery_date            :date
#  comment                  :text(65535)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  delivered                :decimal(20, 5)   default(0.0)
#  accepted                 :decimal(20, 5)   default(0.0)
#  rejected                 :decimal(20, 5)   default(0.0)
#  category_id              :integer
#  cost_center_id           :integer
#  is_deleted               :boolean          default(FALSE), not null
#  account                  :string(255)
#  tax_rate_id              :integer
#  deleted_at               :datetime
#  submitted_at             :datetime
#  approved_at              :datetime
#  unit_of_measurement      :string(255)
#  purchase_request_item_id :integer
#  department_id            :integer
#  cgst                     :decimal(20, 10)
#  sgst                     :decimal(20, 5)   default(0.0)
#  igst                     :decimal(20, 5)   default(0.0)
#  taxable_amount_id        :integer
#  previously_billed_amount :decimal(20, 5)   default(0.0)
#  tds_applicable           :boolean          default(FALSE)
#  company_id               :integer
#

class PurchaseOrderItem < ApplicationRecord
  attr_accessor :skip_callback, :pr_number
  include LiquidDroppable
  include Exposures::Model::Exposable
  include FormsHelper

  validates :inventory_line_item_id, presence: true

  belongs_to :company, optional: true
  belongs_to :tax_rate, optional: true
  belongs_to :purchase_order, optional: true
  belongs_to :inventory_line_item, optional: true, class_name: 'Item'
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :taxable_amount, optional: true, class_name: "Amount"
  belongs_to :discount_amount, optional: true, class_name: "Amount"
  belongs_to :total_amount, optional: true, class_name: "Amount"
  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :department, optional: true
  belongs_to :product_type, optional: true
  belongs_to :purchase_request_item, optional: true

  alias_attribute :items_department_id, :department_id
  alias_attribute :items_cost_center_id, :cost_center_id

  alias_method :items_department, :department
  alias_method :items_cost_center, :cost_center

  def get_reporting_currency
    self.purchase_order.get_reporting_currency rescue self.company.reporting_currency
  end

  def get_base_currency
    self.purchase_order.get_base_currency rescue self.company.reporting_currency
  end
  
  def exchange_rate
    ExchangeRate.get_rate(
        self.purchase_order.conversion_date,
        self.purchase_order.reporting_currency,
        self.purchase_order.get_base_currency&.country_code || "INR"
    )
  end

  # link to budget trails table
  has_many :budget_trails, as: :entity
  has_paper_trail(
      meta: {
          parent_document_type: "Purchase Order"
      }
  )

  # removing for now
  # validates_presence_of :unit_of_measurement
  # validates_presence_of :department
  # validates_presence_of :rate

  accepts_nested_attributes_for :tax_amount, :discount_amount, :taxable_amount,
                                :total_amount

  scope :with_id, -> (ids) {
    where(id: ids)
  }

  scope :without_id, -> (ids) {
    where.not(id: ids)
  }

  scope :with_inventory_line_item, -> (inventory_line_item_id) {
    where inventory_line_item_id: inventory_line_item_id
  }

  scope :with_purchase_order_id, -> (purchase_order_ids){
    where purchase_order_id: purchase_order_ids
  }

  scope :with_category, -> (id) {
    where category_id: id
  }

  scope :with_budgetable_category_ids, -> (category_ids) {
    if category_ids.present?
      category_ids = [category_ids] unless category_ids.is_a?(Array)
      where(category_id: category_ids)
    end
  }

  scope :with_budgetable_cost_center_ids, -> (cost_center_ids) {
    if cost_center_ids.present?
      cost_center_ids = [cost_center_ids] unless cost_center_ids.is_a?(Array)
      where(cost_center_id: cost_center_ids)
    end
  }

  scope :include_details, -> {includes(:total_amount, :cost_center,purchase_order: [:department, :location])}
  scope :include_for_show,  -> {includes(:inventory_line_item,:category,:purchase_request_item,:taxable_amount,:tax_amount, :discount_amount,:total_amount,:tax_rate)}

  before_save :set_tds_applicable
  after_save :sync_amounts, unless: :skip_callback
  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy

  def tax
    self.tax_rate&.rate || super
  end

  def before_tax_amount
    if parent_forms_enabled
      self.reporting_item_taxable_amount.to_f
    else
      self.taxable_amount&.value.to_f
    end
  end

  def after_tax_amount
    if parent_forms_enabled
      self.reporting_item_net_amount.to_f
    else
      self.total_amount&.value.to_f
    end
  end

  def set_tds_applicable
    self.tds_applicable = self&.inventory_line_item&.tds_applicable
    true
  end

  def retrieve_value(entity)  
    send("#{entity.entity_key.gsub('_id', '')}")&.name rescue send(entity.entity_key)
  end

  def parent_forms_enabled
    purchase_order.forms_enabled
  end

  def sync_amounts
    if parent_forms_enabled
      self.skip_callback = true
      base_currency_id = purchase_order.get_base_currency&.id
      
      if self.purchase_order.procurement.invoices.count == 0

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

        unless purchase_order.cost_allocation_items
          self.department_id = purchase_order&.department_id
          self.cost_center_id = purchase_order&.cost_center_id
        end

        self.tax_percentage = self.tax_rate&.rate.to_f
      end
      self.save
    end
  end

  def amounts_attributes_map
    {
      item_discount_amount: 'discount_amount',
      item_taxable_amount: 'taxable_amount',
      item_tax_amount: 'tax_amount',
      item_net_amount: 'total_amount'
    }
  end

  def invoiced_total_amount
    invoiced_amount = 0.0
    if self.inventory_line_item&.product_type_id ==  ProductType.id_for(:goods)
      invoiced_line_items = self.purchase_order.procurement.invoices.scope_all_except_voided.joins(items: :taxable_amount).where('invoice_line_items.purchase_order_item_id = ?', self.id)
      invoiced_amount = invoiced_line_items.sum('amounts.value')&.round(2)
    else
      invoiced_line_items = self.purchase_order.procurement.invoices.scope_all_except_voided.joins(items: :billable_amount).where('invoice_line_items.purchase_order_item_id = ?', self.id)
      invoiced_amount = invoiced_line_items.sum('amounts.value')&.round(2)
    end
    invoiced_amount
  end

  def pr_number
    self.purchase_request_item&.purchase_request.order_number
  end

  private

  def budget_trail_entry
    if self.purchase_order.voided?
      BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(self)
    else
      BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(self)
    end
  end

  def budget_trail_destroy
    BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(self)
  end


  def set_currency_for_amount
    amount_attr = [:tax_amount ,:taxable_amount ,:discount_amount ,:total_amount]

    amount_attr.each do |amount_attribute|
      amount_attr_id = self.send("#{amount_attribute}_id")
      if amount_attr_id.present?
        Amount.find_by(id: amount_attr_id).update(currency_id: self.purchase_order.get_base_currency.id)
      end
    end
    self.skip_callback = true
    self.save
  end

end

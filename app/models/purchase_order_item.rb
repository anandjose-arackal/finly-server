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
#  unit_of_measurement      :string(255)
#  purchase_request_item_id :integer
#  department_id            :integer
#  cgst                     :decimal(20, 10)
#  sgst                     :decimal(20, 5)   default(0.0)
#  igst                     :decimal(20, 5)   default(0.0)
#  taxable_amount_id        :integer
#  previously_billed_amount :decimal(20, 5)   default(0.0)
#

class PurchaseOrderItem < ApplicationRecord
  validates :inventory_line_item_id, presence: true
  # validates :purchase_order_id, presence: true

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
  belongs_to :purchase_request_item, optional: true

  # link to budget trails table
  has_many :budget_trails, as: :entity

  # removing for now
  # validates_presence_of :unit_of_measurement
  validates_presence_of :department
  validates_presence_of :rate

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
  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy


  def tax
    self.tax_rate&.rate || super
  end

  def before_tax_amount
    self.taxable_amount&.value.to_f
  end

  def after_tax_amount
    self.total_amount&.value.to_f
  end

  def set_tds_applicable
    self.tds_applicable = self.inventory_line_item.tds_applicable
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

end

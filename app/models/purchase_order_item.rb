# == Schema Information
#
# Table name: purchase_order_items
#
#  id                     :integer          not null, primary key
#  purchase_order_id      :integer
#  inventory_line_item_id :integer
#  product_id             :string(255)
#  description            :string(255)
#  hsn_sac                :string(255)
#  quantity               :integer
#  rate                   :decimal(20, 5)
#  tax                    :decimal(20, 5)
#  tds                    :decimal(20, 5)
#  discount               :decimal(20, 5)
#  tax_amount_id          :integer
#  tds_amount_id          :integer
#  discount_amount_id     :integer
#  total_amount_id        :integer
#  delivery_date          :date
#  comment                :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  delivered              :integer          default(0)
#  accepted               :integer          default(0)
#  rejected               :integer          default(0)
#  category_id            :integer
#  cost_center_id         :integer
#  is_deleted             :boolean          default(FALSE), not null
#  account                :string(255)
#  tax_rate_id            :integer
#  deleted_at             :datetime
#

class PurchaseOrderItem < ApplicationRecord
  include SoftDeletable
  validates :inventory_line_item_id, presence: true
  # validates :purchase_order_id, presence: true

  belongs_to :tax_rate, optional: true
  belongs_to :purchase_order, optional: true
  belongs_to :inventory_line_item, optional: true
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :discount_amount, optional: true, class_name: "Amount"
  belongs_to :total_amount, optional: true, class_name: "Amount"
  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true

  # link to budget trails table
  has_many :budget_trails, as: :entity

  accepts_nested_attributes_for :tax_amount, :discount_amount,
                                :total_amount

  scope :with_id, -> (ids) {
    where(id: ids)
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
      ids = joins(:inventory_line_item).where("inventory_line_items.category_id IN (?)", category_ids).pluck('purchase_order_items.id')
      where(id: ids)
    end
  }

  scope :with_budgetable_cost_center_ids, -> (cost_center_ids) {
    if cost_center_ids.present?
      cost_center_ids = [cost_center_ids] unless cost_center_ids.is_a?(Array)
      where(cost_center_id: cost_center_ids)
    end
  }

  scope :include_details, -> {includes(:total_amount, :cost_center,purchase_order: [:department, :location])}

  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy


  def tax
    self.tax_rate&.rate || super
  end

  private

  def budget_trail_entry
    # if PurchaseOrderStatus.ids_for([:approved, :auto_approved, :sent_to_vendor, :closed]).include?(self.purchase_order&.purchase_order_status_id)
    #   calling the trail saving processor method that will take care of saving the budget trail
      # BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(self)
    # else
    #   BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(self)
    # end
    if self.purchase_order.voided? || self.purchase_order.rejected? || self.purchase_order.retracted? || self.purchase_order.open?
      BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(self)
    else
      BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.save_trail(self)
    end
  end

  def budget_trail_destroy
    BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor.new.destroy_trail(self)
  end

end

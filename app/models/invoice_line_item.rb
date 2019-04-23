# == Schema Information
#
# Table name: invoice_line_items
#
#  id                     :integer          not null, primary key
#  invoice_id             :integer
#  description            :string(255)
#  quantity               :integer
#  rate                   :decimal(20, 10)
#  tax                    :decimal(20, 10)
#  discount               :decimal(20, 10)
#  category_id            :integer
#  gst_type_id            :integer
#  tax_amount_id          :integer
#  discount_amount_id     :integer
#  amount_id              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  net_amount_id          :integer
#  hsn_sac                :string(255)
#  taxable_amount_id      :integer
#  parent_type            :string(255)
#  parent_id              :string(255)
#  inventory_line_item_id :integer
#  item_info              :text(65535)
#  comment                :text(65535)
#  account                :string(255)
#  tax_rate_id            :integer
#  cost_center_id         :integer
#  unit_of_measurement    :string(255)
#

class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :category, optional: true
  belongs_to :amount, optional: true
  belongs_to :discount_amount, optional: true, class_name: "Amount"
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :net_amount, optional: true, class_name: "Amount"
  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :taxable_amount, optional: true, class_name: "Amount"
  belongs_to :inventory_line_item, optional: true, class_name: 'Item'
  belongs_to :gst_type, optional: true
  belongs_to :tax_rate, optional: true

  has_many :custom_fields, as: :parent, dependent: :destroy

  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :net_amount

  validates :description, presence: true
  validates :quantity, presence: true
  validates :rate, presence: true
  # removing for now
  # validates_presence_of :unit_of_measurement

  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy

  def tax
    self.tax_rate&.rate || super
  end

  scope :with_id, -> (id) {
    where id: id
  }
  scope :with_parent_type, -> (type) {
    where parent_type: type
  }

  scope :with_parent_id, -> (ids) {
    where parent_id: ids
  }

  scope :with_budgetable_category_ids, -> (category_ids) {
    if category_ids.present?
      category_ids = [category_ids] unless category_ids.is_a?(Array)
      # ids = joins(:inventory_line_item).where("inventory_line_items.category_id IN (?)", category_ids).pluck('invoice_line_items.id')
      ids = joins(:inventory_line_item).where("items.category_id IN (?)", category_ids).pluck('items.id')
      where(id: ids)
    end
  }

  scope :with_budgetable_cost_center_ids, -> (cost_center_ids) {
    # todo - add cost center to invoice line items
    # if cost_center_ids.present?
    #   cost_center_ids = [cost_center_ids] unless cost_center_ids.is_a?(Array)
    #   where(cost_center_id: cost_center_ids)
    # end
  }

  private

  def budget_trail_entry
    if self.parent&.is_a?(Invoice)
      if self.parent.open? || self.parent.rejected? || self.parent.retracted?
        BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(self)
      else
        BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.save_trail(self)
      end
    end
  end

  def budget_trail_destroy
    if self.parent&.is_a?(Invoice)
      BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(self)
    end
  end
end

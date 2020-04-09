# == Schema Information
#
# Table name: invoice_line_items
#
#  id                     :integer          not null, primary key
#  invoice_id             :integer
#  description            :text(65535)
#  quantity               :decimal(20, 5)
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
#  department_id          :integer
#  sgst                   :decimal(20, 5)   default(0.0)
#  cgst                   :decimal(20, 5)   default(0.0)
#  igst                   :decimal(20, 5)   default(0.0)
#  purchase_order_item_id :integer
#  billable_amount_id     :integer
#  deleted_at             :datetime
#

class InvoiceLineItem < ApplicationRecord
  include LiquidDroppable
  include Exposures::Model::Exposable
  include MathUtil

  belongs_to :invoice, optional: true
  belongs_to :category, optional: true
  belongs_to :amount, optional: true
  belongs_to :discount_amount, optional: true, class_name: "Amount"
  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :net_amount, optional: true, class_name: "Amount"
  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :taxable_amount, optional: true, class_name: "Amount"
  belongs_to :billable_amount, optional: true, class_name: "Amount"
  belongs_to :inventory_line_item, optional: true, class_name: 'Item'
  belongs_to :gst_type, optional: true
  belongs_to :tax_rate, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :department, optional: true
  belongs_to :purchase_order_item, optional: true

  has_many :custom_fields, as: :parent, dependent: :destroy

  delegate :goods?, :service?, to: :inventory_line_item

  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :net_amount
  accepts_nested_attributes_for :taxable_amount
  accepts_nested_attributes_for :billable_amount

  validates :description, presence: true
  validates :quantity, presence: true
  validates :rate, presence: true

  # removing for now
  # validates_presence_of :unit_of_measurement
  # validates_presence_of :department, if: :check_outward_invoice?
  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy

  TEMPLATE_COLUMNS = %w{ description quantity rate tax discount category_id gst_type_id hsn_sac parent_type parent_id inventory_line_item_id item_info comment account tax_rate_id cost_center_id unit_of_measurement department_id sgst cgst igst }
  CLONE_RECORDS = %w{ tax_amount_id discount_amount_id amount_id net_amount_id taxable_amount_id billable_amount_id}

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

  scope :with_invoice_id, -> (invoice_id) {where invoice_id: invoice_id}

  def before_tax_amount
    self.taxable_amount&.value.to_f
  end

  def after_tax_amount

    self.net_amount&.value.to_f
  end


  def check_outward_invoice?
    return true if self.parent_type != 'OutwardInvoice'
  end

  def tds_applicable?
    self.inventory_line_item&.tds_applicable?
  end

  def as_json(options = {})
    {
        id: self.id,
        description: self.description,
        quantity: self.quantity,
        rate: self.rate,
        tax: self.tax,
        discount: self.discount,
        category_id: self.category_id,
        category_name: category&.name,
        gst_type_id: self.gst_type_id,
        tax_amount_id: self.tax_amount_id,
        tax_amount: precision_value(tax_amount&.value),
        discount_amount: precision_value(discount_amount&.value),
        amount: precision_value(amount&.value),
        discount_amount_attributes: {id: self.discount_amount_id, value: precision_value(self.discount_amount&.value), currency_id: self.discount_amount&.currency_id},
        amount_attributes: {id: self.amount_id, value: precision_value(self.amount&.value), currency_id: self.amount&.currency_id},
        total_amount: precision_value(net_amount&.value),
        net_amount_attributes: {id: self.net_amount_id, value: precision_value(self.net_amount&.value), currency_id: self.net_amount&.currency_id, line_item_id: self.id},
        hsn_sac: self.hsn_sac,
        taxable_amount: precision_value(taxable_amount&.value),
        taxable_amount_id: {id: self.taxable_amount_id, value: precision_value(self.taxable_amount&.value), currency_id: self.taxable_amount&.currency_id},
        inventory_line_item_id: self.inventory_line_item_id,
        item_info: self.item_info,
        comment: self.comment,
        account: self.account,
        tax_rate: self.tax_rate.as_json,
        cost_center: self.cost_center.as_json,
        unit_of_measurement: self.unit_of_measurement,
        department: self.department.as_json,
        tds_applicable: tds_applicable?
    }
  end

  def update_taxable_amount_value
    rate = self.rate
    quantity = self.quantity
    discount_percentage = self.discount
    amount_before_discount = rate*quantity
    taxable_amt = amount_before_discount - (amount_before_discount*discount.to_f/100)
    if self.taxable_amount.present?
      self.taxable_amount.update_column('value', taxable_amt)
    else
      self.create_taxable_amount(value: taxable_amt, currency_id: 1)
    end
  end

  def update_net_amount_value
    taxable_amt = self.taxable_amount.value
    tax_percentage = self.tax_rate.rate
    net_value = taxable_amt + (taxable_amt*tax_percentage.to_f/100)
    if self.net_amount.present?
      self.net_amount.update(value: net_value)
    else
      self.create_net_amount(value: net_value, currency_id: 1)      
    end
  end

  def update_tax_amount_value
    taxable_amt = self.taxable_amount.value
    tax_percentage = self.tax_rate.rate
    tax_value = taxable_amt*tax_percentage.to_f/100
    if self.tax_amount.present?
      self.tax_amount.update(value: tax_value)
    else
      self.create_tax_amount(value: tax_value, currency_id: 1)
    end
  end

  def tds_amount
    service? ? calculate_tds(self.billable_amount&.value.to_f) : calculate_tds(self.taxable_amount&.value.to_f)
  end


  def cn_adjusted_amount_with_tax
    # applied_credit_notes = self.parent.credit_notes
    # adjusted_amount = (applied_credit_notes.joins(:gross_receivable_amount).sum(:value) + applied_credit_notes.joins(:tax_amount).sum(:value)) * ((self.after_tax_amount) / (self.parent.amount_after_tax)) rescue 0
    adjusted_amount = self.parent.credit_note_adjustments.joins(:amount).sum(:value) * ((self.after_tax_amount) / (self.parent.amount_after_tax)) rescue 0
    adjusted_amount
  end

  def cn_adjusted_amount_without_tax
    applied_credit_notes = self.parent.credit_notes
    adjusted_amount = [(self.parent.credit_note_adjustments.joins(:amount).sum(:value) - applied_credit_notes.joins(:tax_amount).sum(:value)), 0].max * ((self.before_tax_amount) / (self.parent.amount_before_tax)) rescue 0
    adjusted_amount
  end


  private

  def budget_trail_entry
    if self.parent&.is_a?(Invoice)
      if self.parent.rejected? || self.parent.voided?
        BudgetManager::BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(self)
      else
        BudgetManager::BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.save_trail(self)
      end
    end
  end

  def budget_trail_destroy
    if self.parent&.is_a?(Invoice)
      BudgetManager::BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(self)
    end
  end

  def tds_percentage
    return 0.0 unless tds_applicable?
    self.parent.tds_slab&.tds || 0.0
  end

  def calculate_tds(amount)
    new_gross_amount = TaxCalculationUtils.tds_amount(amount, tds_percentage)
    tds_amount = (amount - new_gross_amount) rescue 0
    tds_amount.ceil
  end

end

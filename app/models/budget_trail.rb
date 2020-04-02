# == Schema Information
#
# Table name: budget_trails
#
#  id                                         :integer          not null, primary key
#  entity_id                                  :integer
#  entity_type                                :string(255)
#  category_id                                :integer
#  cost_center_id                             :integer
#  location_id                                :integer
#  vendor_id                                  :integer
#  amount_id                                  :integer
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  user_id                                    :integer
#  department_id                              :integer
#  entity_date                                :date
#  sub_department_id                          :integer
#  procurement_id                             :integer
#  entity_status_id                           :integer
#  amount_before_tax_id                       :integer
#  amount_after_tax_id                        :integer
#  entity_created_at                          :datetime
#  entity_submitted_at                        :datetime
#  billed                                     :boolean          default(FALSE)
#  deleted_at                                 :datetime
#  date                                       :datetime
#  amount_after_tax_value                     :decimal(20, 10)
#  amount_before_tax_value                    :decimal(20, 10)
#  po_trail_item_id                           :integer
#  remaining_amount_value                     :decimal(20, 10)
#  billed_quantity                            :integer
#  remaining_quantity                         :integer
#  revised                                    :boolean          default(FALSE)
#  billed_amount_before_tax_value             :decimal(20, 10)
#  remaining_amount_after_tax_value           :decimal(20, 10)
#  billed_amount_after_tax_value              :decimal(20, 10)
#  remaining_amount_before_tax_value          :decimal(20, 10)
#  purchase_order_id                          :integer
#  invoice_id                                 :integer
#  payment_purpose_id                         :integer
#  effective_paid_amount_before_tax_value     :decimal(20, 10)  default(0.0)
#  paid_amount_after_tax_value                :decimal(20, 10)  default(0.0)
#  reimbursable                               :boolean          default(FALSE)
#  payment_processing_amount_before_tax_value :decimal(20, 10)  default(0.0)
#  payment_processing_amount_after_tax_value  :decimal(20, 10)  default(0.0)
#  tds_value                                  :decimal(20, 10)  default(0.0)
#  tax_amount_value                           :decimal(20, 10)  default(0.0)
#  net_paid_amount_before_tax_value           :decimal(20, 10)
#

class BudgetTrail < ApplicationRecord

  belongs_to :entity, optional: true, polymorphic: true
  belongs_to :category, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :amount, optional: true
  belongs_to :vendor, optional: true, class_name: "YesBankVendor"
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :department, optional: true
  belongs_to :sub_department, optional: true, class_name: "Department"
  belongs_to :user, optional: true
  belongs_to :procurement, optional: true
  belongs_to :amount_after_tax, class_name: "Amount"
  belongs_to :amount_before_tax, class_name: "Amount"
  belongs_to :po_trail_item, class_name: "BudgetTrail", optional: true

  after_save :set_po_trail_attributes

  accepts_nested_attributes_for :amount, :amount_after_tax, :amount_before_tax

  scope :within_date, -> (start_date, end_date, date_to_be_considered) {
    where("#{date_to_be_considered} >= ? AND #{date_to_be_considered} <= ?", start_date.beginning_of_day, end_date.end_of_day)
  }

  scope :billed, -> {
    where billed: true
  }

  scope :not_billed, -> {
    where billed: false
  }

  scope :joins_amount, -> { joins(:amount) }
  scope :with_users, -> (user_ids) {
    unless user_ids.blank?
      where(user_id: user_ids)
    end
  }

  scope :with_departments, -> (department_ids) {
    where department_id: department_ids
  }

  scope :with_departments_or_sub_departments, -> (department_ids) {
    unless department_ids.blank?
      # ids = where(department_id: department_ids).pluck(:id)
      # ids += where(sub_department_id: department_ids).pluck(:id)
      where('department_id IN (?) OR sub_department_id IN (?)', department_ids, department_ids)
    end
  }

  scope :reimbursable, -> {
    where reimbursable: true
  }

  scope :not_revised, -> {
    where.not revised: true
  }

  scope :without_invoice_or_po, -> {
    where(invoice_id: nil, purchase_order_id: nil)
  }

  scope :with_locations, -> (location_ids) {
    unless location_ids.blank?
      where(location_id: location_ids)
    end
  }
  scope :with_vendors, -> (vendor_ids) {
    unless vendor_ids.blank?
      where(vendor_id: vendor_ids)
    end
  }
  scope :with_categories, -> (category_ids) {
    unless category_ids.blank?
      where(category_id: category_ids)
    end
  }
  scope :with_cost_centers, -> (cost_center_ids) {
    unless cost_center_ids.blank?
      where(cost_center_id: cost_center_ids)
    end
  }
  scope :with_budgetable_entities, -> (budgetable_entities) {
    where(entity_type: budgetable_entities)
  }
  # more or less the same as with_budgetable_entities
  scope :with_entity_type, -> (entity_types) {
    where(entity_type: entity_types)
  }

  scope :with_entity_id, -> (ids) {
    where entity_id: ids
  }

  scope :with_entity_status_id, -> (entity_status_id) {
    where entity_status_id: entity_status_id
  }

  private

  # here we are reducing the amounts against each line item to match the amount that has been invoices
  # so that it doesn't consume the budget twice.
  # Additionally, we also have to prorporionally reduce the TDS (if any) in the invoice and proportionally subtract it from the remaining amount of the PO
  def set_po_trail_attributes
    if self.po_trail_item_id.present?
      invoice_trails = BudgetTrail.where(entity_type: "InvoiceLineItem", po_trail_item_id: self.po_trail_item_id)
      remaining_amount_before_tax = po_trail_item.amount_before_tax&.value.to_f - invoice_trails.sum(:billed_amount_before_tax_value)
      remaining_amount_after_tax = po_trail_item.amount_after_tax&.value.to_f - invoice_trails.sum(:billed_amount_after_tax_value)
      remaining_quantity = po_trail_item&.entity&.quantity - invoice_trails.sum(:billed_quantity)
      po_trail_item.update_columns(remaining_amount_before_tax_value: remaining_amount_before_tax, remaining_amount_after_tax_value: remaining_amount_after_tax, remaining_quantity: remaining_quantity)
    end
  end

end

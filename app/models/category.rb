# == Schema Information
#
# Table name: categories
#
#  id                         :integer          not null, primary key
#  company_id                 :integer          not null
#  name                       :string(255)      not null
#  gl_code                    :string(255)
#  payroll_code               :string(255)
#  active                     :boolean          default(TRUE), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  purpose_id                 :integer
#  expense_management         :boolean
#  vendor_payments            :boolean
#  outward_invoices           :boolean
#  inward_invoice_line_items  :boolean
#  ancestry                   :string(255)
#  outward_invoice_line_items :boolean
#  category_code              :string(255)
#

class Category < ApplicationRecord
  include AncestrySupport
  include Sequenced::ActsAsSequenced

  acts_as_sequenced column: :category_code, purpose: :category, editable: false, prefix: 'CAT'
  has_ancestry

  belongs_to :company, optional: true

  has_one :quickbooks_category, dependent: :destroy

  has_many :budget_criteria_mappings, as: :budgetable
  has_many :budgets, through: :budget_criteria_mappings

  validates :company_id, presence: true
  validates :name, presence: true, uniqueness: {scope: [:company_id, :ancestry]}
  # validate :at_least_one_application

  default_scope { order(name: :asc) }

  # returns the name of the category
  def category_name
    self.name
  end

  scope :active, -> { where active: true }
  scope :with_id, ->(id) { where id: id }
  scope :with_name, ->(name) { where name: name }
  scope :others, -> { where name: 'Other' }
  scope :with_purpose, -> (purposes) {
    if Category.column_names.include?(purposes)
      if purposes.is_a?(Array)
        ids = []
        purposes.each do |purpose|
          ids += where(purpose.to_sym => true).pluck(:id)
        end
        where id: ids
      else
        where(purposes.to_sym => true)
      end
    end
  }
  scope :outward_invoice_items_categories, -> { where purpose_id: Purpose.id_for(:outward_invoice_items) }
  scope :expense_management_only, -> {
    where expense_management: true
  }
  scope :vendor_payments_only, -> {
    where(vendor_payments: true)
  }

  scope :inward_invoices_only, -> {
    where vendor_payments: true
  }

  scope :outward_invoices_only, -> {
    where purpose_id: Purpose.id_for(:outward_invoices)
  }
  scope :inward_invoice_items_only, -> {
    where inward_invoice_line_items: true
  }
  scope :inward_invoice_line_items_only, -> {
    where inward_invoice_line_items: true
  }

  scope :outward_invoice_items_only, -> {
    where outward_invoice_line_items: true
  }
  scope :outward_invoice_line_items_only, -> {
    where outward_invoice_line_items: true
  }

  scope :from_application, -> (application) {
    if Category.column_names.include?(application)
      if application.is_a?(Array)
        ids = []
        application.each do |app|
          ids += where(app.to_sym => true).pluck(:id)
        end
        where id: ids
      else
        where(application.to_sym => true)
      end
    end
  }

  scope :filter_search, -> (term) {
    where('name like ?', "%#{term}%")
  }

  # scope :leaves, -> {
  #   id = pluck(:id)
  #   non_leaves = Category.where(ancestry: id).pluck(:ancestry)&.map {|item| item.to_i}
  #   leaves = id - non_leaves
  #   where id: leaves
  # }

  def gl_name
    gl_code || name
  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

  private

  # def at_least_one_application
  #   if !self.expense_management && !self.vendor_payments && !self.outward_invoices && !self.outward_invoice_line_items && !self.inward_invoice_line_items
  #     errors.add(:category, "must belong to at least one application")
  #   end
  # end
end

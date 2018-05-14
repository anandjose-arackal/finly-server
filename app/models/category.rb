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
#










class Category < ActiveRecord::Base
  has_ancestry

  belongs_to :company

  has_one :quickbooks_category, dependent: :destroy

  validates :company_id, presence: true
  validates :name, presence: true, uniqueness: {scope: :company_id}
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
  scope :with_purpose, -> (purpose) {
    if purpose.present?
      where(purpose.to_sym => true)
    end
  }
  scope :outward_invoice_items_categories, -> { where purpose_id: Purpose.id_for(:outward_invoice_items) }
  scope :expense_management_only, -> {
    where purpose_id: Purpose.id_for(:expense_management)
  }
  scope :vendor_payments_only, -> {
    where purpose_id: Purpose.id_for(:vendor_payments)
  }
  scope :outward_invoices_only, -> {
    where purpose_id: Purpose.id_for(:outward_invoices)
  }
  scope :inward_invoice_items_only, -> {
    where inward_invoice_line_items: true
  }
  scope :outward_invoice_items_only, -> {
    where outward_invoice_line_items: true
  }

  scope :from_application, -> (application) {
    if Category.column_names.include?(application)
      where(application.to_sym => true)
    end
  }

  scope :filter_search, -> (term) {
    where('name like ?', "%#{term}%")
  }

  private

  # def at_least_one_application
  #   if !self.expense_management && !self.vendor_payments && !self.outward_invoices && !self.outward_invoice_line_items && !self.inward_invoice_line_items
  #     errors.add(:category, "must belong to at least one application")
  #   end
  # end
end

# == Schema Information
#
# Table name: categories
#
#  id           :integer          not null, primary key
#  company_id   :integer          not null
#  name         :string(255)      not null
#  gl_code      :string(255)
#  payroll_code :string(255)
#  active       :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  purpose_id   :integer
#






class Category < ActiveRecord::Base
  belongs_to :company
  belongs_to :purpose

  has_one :quickbooks_category, dependent: :destroy

  validates :company_id, presence: true
  validates :name, presence: true, uniqueness: {scope: :company_id}

  default_scope { order(name: :asc) }

  # returns the name of the category
  def category_name
    self.name
  end

  scope :active, -> { where active: true }
  scope :with_id, ->(id) { where id: id }
  scope :with_name, ->(name) { where name: name }
  scope :others, -> { where name: 'Other' }
  scope :with_purpose, -> (purpose_id) {
    where purpose_id: purpose_id
  }
  scope :outward_invoice_items_categories, -> { where purpose_id: Purpose.id_for(:outward_invoice_items) }
  scope :expense_management_only, -> {
    where purpose_id: Purpose.id_for(:expense_management)
  }
  scope :vendor_payments_only, -> {
    where purpose_id: Purpose.id_for(:vendor_payments)
  }
  scope :invoices_only, -> {
    where purpose_id: Purpose.id_for(:invoice)
  }
end

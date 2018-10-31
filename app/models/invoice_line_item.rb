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
#  comment                :string(255)
#  account                :string(255)
#  tax_rate_id            :integer
#  buying_price           :decimal(10, 5)
#  markup                 :decimal(10, 5)
#  profit                 :decimal(10, 5)
#  customer_id            :integer
#  brand                  :string(255)
#  model_number           :string(255)
#  date_of_inward         :string(255)
#  year_of_registration   :string(255)
#  kms_driven             :decimal(10, 5)
#  expected_selling_price :decimal(10, 5)
#  owner_details          :string(255)
#  parking_charges        :decimal(10, 5)
#  billable               :boolean
#  registration_number    :string(255)
#  vendor_id              :integer
#

class InvoiceLineItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :category
  belongs_to :amount
  belongs_to :discount_amount, class_name: "Amount"
  belongs_to :tax_amount, class_name: "Amount"
  belongs_to :net_amount, class_name: "Amount"
  belongs_to :parent, polymorphic: true
  belongs_to :taxable_amount, class_name: "Amount"
  belongs_to :inventory_line_item
  belongs_to :gst_type
  belongs_to :tax_rate

  has_many :custom_fields, as: :parent, dependent: :destroy

  accepts_nested_attributes_for :discount_amount
  accepts_nested_attributes_for :tax_amount
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :net_amount

  validates :description, presence: true
  validates :quantity, presence: true
  validates :rate, presence: true

  after_save :budget_trail_entry
  after_destroy :budget_trail_destroy

  def tax
    self.tax_rate&.rate || super
  end

  scope :with_id, -> (id) {
    where id: id
  }

  private

  def budget_trail_entry
    if self.parent&.is_a?(Invoice)
      BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.save_trail(self)
    end
  end

  def budget_trail_destroy
    if self.parent&.is_a?(Invoice)
      BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor.new.destroy_trail(self)
    end
  end
end

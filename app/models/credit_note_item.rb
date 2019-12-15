# == Schema Information
#
# Table name: credit_note_items
#
#  id                         :bigint           not null, primary key
#  credit_note_id             :integer
#  item_id                    :integer
#  invoice_item_id            :integer
#  category_id                :integer
#  credit_note_item_type_id   :integer
#  comment                    :text(65535)
#  gl_code                    :string(255)
#  hsn_sac                    :string(255)
#  original_quantity          :decimal(20, 5)
#  revised_quantity           :decimal(20, 5)
#  quantity                   :decimal(20, 5)
#  original_rate              :decimal(20, 5)
#  revised_rate               :decimal(20, 5)
#  rate                       :decimal(20, 5)
#  original_taxable_amount_id :integer
#  revised_taxable_amount_id  :integer
#  taxable_amount_id          :integer
#  original_tax_rate_id       :integer
#  revised_tax_rate_id        :integer
#  tax_rate_id                :integer
#  total_amount_id            :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  deleted_at                 :datetime
#  tax_amount_id              :integer
#

class CreditNoteItem < ApplicationRecord
  include MathUtil

  before_save :calculate_total

  belongs_to :item, class_name: 'Item', optional: true
  belongs_to :invoice_item, class_name: 'InvoiceLineItem', optional: true
  belongs_to :category, class_name: 'Category', optional: true
  belongs_to :credit_note_item_type, class_name: 'CreditNoteItemType', optional: true
  belongs_to :parent, class_name: 'CreditNote', foreign_key: 'credit_note_id', optional: true

  belongs_to :original_taxable_amount, class_name: 'Amount', optional: true
  belongs_to :taxable_amount, class_name: 'Amount', optional: true

  belongs_to :original_tax_rate, class_name: 'TaxRate', optional: true
  belongs_to :tax_rate, class_name: 'TaxRate', optional: true
  belongs_to :tax_amount, class_name: 'Amount', optional: true
  belongs_to :total_amount, class_name: 'Amount', optional: true

  def as_json(options={})
    {
        id: id,
        description: item&.description,
        original_quantity: original_quantity,
        quantity: quantity,
        category: category.as_json,
        comment: comment,
        hsn_sac: hsn_sac,
        credit_note_item_type: credit_note_item_type,
        original_rate: original_rate,
        rate: rate,
        original_taxable_amount: original_taxable_amount.as_json,
        taxable_amount: taxable_amount.as_json,
        original_tax_rate: original_tax_rate.as_json,
        tax_rate: tax_rate.as_json,
        total_amount: total_amount.as_json
    }

  end

  def total_amount_value
    total_amount.value
  end

  private

  def calculate_total
    currency_id = parent&.company&.base_currency_id || Currency.id_for("INR")
    taxable_amount_value = quantity * rate
    tax_amount_value = taxable_amount_value * self.tax_rate.rate / 100

    if self.taxable_amount.present?
      self.taxable_amount.value = taxable_amount_value
    else
      self.taxable_amount = Amount.new(value: taxable_amount_value, currency_id: currency_id)
    end

    if self.tax_amount.present?
      self.tax_amount.value = tax_amount_value
    else
      self.tax_amount = Amount.new(value: (tax_amount_value), currency_id: currency_id)
    end

    if self.total_amount.present?
      self.total_amount.value = tax_amount_value + taxable_amount_value
    else
      self.total_amount = Amount.new(value: (tax_amount_value + taxable_amount_value), currency_id: currency_id)
    end
  end
end

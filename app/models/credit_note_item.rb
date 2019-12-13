# == Schema Information
#
# Table name: credit_note_items
#
#  id                         :bigint           not null, primary key
#  credit_note_id             :integer
#  item_id                    :integer
#  invoice_item_id            :integer
#  category_id                :integer
#  credit_note_item_type      :integer
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
#

class CreditNoteItem < ApplicationRecord
  include MathUtil

  before_save :calculate_total

  belongs_to :item, class_name: 'Item', optional: true
  belongs_to :invoice_item, class_name: 'InvoiceLineItem', optional: true
  belongs_to :category, class_name: 'Category', optional: true

  belongs_to :original_taxable_amount, class_name: 'Amount', optional: true
  belongs_to :taxable_amount, class_name: 'Amount', optional: true

  belongs_to :original_tax_rate, class_name: 'TaxRate', optional: true
  belongs_to :tax_rate, class_name: 'TaxRate', optional: true

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

  private

  def calculate_total
    after_discount = quantity * rate
    tax_amount = after_discount * self.tax_rate.rate / 100

    if self.total_amount.present?
      self.total_amount.value = tax_amount + after_discount
    else
      self.total_amount = Amount.new(value: (tax_amount + after_discount), currency_id: 1)
    end
  end

end

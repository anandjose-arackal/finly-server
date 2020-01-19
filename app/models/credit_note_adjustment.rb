# == Schema Information
#
# Table name: credit_note_adjustments
#
#  id             :bigint           not null, primary key
#  invoice_id     :integer
#  credit_note_id :integer
#  amount_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  uuid           :string(36)
#

class CreditNoteAdjustment < ApplicationRecord
  include SoftDeletable

  belongs_to :amount, optional: true
  belongs_to :credit_note, optional: true
  belongs_to :invoice, optional: true

  accepts_nested_attributes_for :amount

  before_create :calculate_credit_note_amounts

  before_update :calculate_adjustable_amount
  after_destroy :calculate_adjustable_amount

  private

  def calculate_credit_note_amounts
    if credit_note.previously_adjusted_amount.present?
      previously_adjusted_amount = credit_note.previously_adjusted_amount.value
      credit_note.previously_adjusted_amount.update(value: previously_adjusted_amount + amount.value)
    else
      credit_note.previously_adjusted_amount = Amount.new(value: previously_adjusted_amount + amount.value, currency_id: 1) # Todo Take care of currency id
    end

    if credit_note.net_adjustable_amount.present?
      net_adjustable_amount = credit_note.net_adjustable_amount.value
      credit_note.net_adjustable_amount.update(value: net_adjustable_amount - amount.value)
    else
      credit_note.net_adjustable_amount = Amount.new(value: net_adjustable_amount - amount.value, currency_id: 1)
    end
  end

  def calculate_adjustable_amount
    # if self.invoice_id.blank?
    if credit_note.previously_adjusted_amount.present?
      previously_adjusted_amount = credit_note.previously_adjusted_amount.value
      credit_note.previously_adjusted_amount.update(value: previously_adjusted_amount - amount.value)
    else
      credit_note.previously_adjusted_amount = Amount.new(value: previously_adjusted_amount - amount.value, currency_id: 1) # Todo Take care of currency id
    end

    if credit_note.net_adjustable_amount.present?
      net_adjustable_amount = credit_note.net_adjustable_amount.value
      credit_note.net_adjustable_amount.update(value: net_adjustable_amount + amount.value)
    else
      credit_note.net_adjustable_amount = Amount.new(value: net_adjustable_amount + amount.value, currency_id: 1)
    end
    # end
  end
end

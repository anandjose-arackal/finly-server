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
#

class CreditNoteAdjustment < ApplicationRecord
  include SoftDeletable, MathUtil

  belongs_to :amount, optional: true
  belongs_to :credit_note, optional: true, touch: true
  belongs_to :invoice, optional: true

  accepts_nested_attributes_for :amount

  # before_create :calculate_credit_note_amounts
  # before_save :truncate_amounts
  #
  # # before_update :calculate_adjustable_amount
  # after_destroy :calculate_adjustable_amount


  def as_json
    {
      id: self.id,
      credit_note_id: self.credit_note&.id,
      credit_note_number: self.credit_note&.credit_note_number,
      credit_note_sequence_id: self.credit_note&.sequence_id,
      amount: self.amount.as_json
    }
  end

  private

  # def calculate_credit_note_amounts
  #   credit_note.touch
  # end

  # def calculate_credit_note_amounts
  #   if credit_note.previously_adjusted_amount.present?
  #     previously_adjusted_amount = credit_note.previously_adjusted_amount.value
  #     credit_note.previously_adjusted_amount.update(value: previously_adjusted_amount + amount.value)
  #   else
  #     credit_note.previously_adjusted_amount = Amount.new(value: previously_adjusted_amount + amount.value, currency_id: 1) # Todo Take care of currency id
  #   end
  #
  #   if credit_note.net_adjustable_amount.present?
  #     net_adjustable_amount = credit_note.net_adjustable_amount.value
  #     credit_note.net_adjustable_amount.update(value: net_adjustable_amount - amount.value)
  #   else
  #     credit_note.net_adjustable_amount = Amount.new(value: net_adjustable_amount - amount.value, currency_id: 1)
  #   end
  #   update_credit_note_status
  # end
  #
  # def calculate_adjustable_amount
  #   # if self.invoice_id.blank?
  #   previously_adjusted_amount = credit_note.previously_adjusted_amount.value
  #   previously_adjusted_amount_value = previously_adjusted_amount - amount.value
  #
  #   if previously_adjusted_amount < 0
  #     previously_adjusted_amount = 0
  #   end
  #
  #   if credit_note.previously_adjusted_amount.present?
  #     credit_note.previously_adjusted_amount.update(value: previously_adjusted_amount)
  #   else
  #     credit_note.previously_adjusted_amount = Amount.new(value: previously_adjusted_amount, currency_id: 1) # Todo Take care of currency id
  #   end
  #
  #   net_adjustable_amount = credit_note.net_adjustable_amount.value
  #   net_adjustable_amount_value = net_adjustable_amount + amount.value
  #
  #   if net_adjustable_amount_value > (credit_note.net_receivable_amount&.value || 0)
  #     net_adjustable_amount_value = (credit_note.net_receivable_amount&.value || 0)
  #   end
  #   if credit_note.net_adjustable_amount.present?
  #     credit_note.net_adjustable_amount.update(value: net_adjustable_amount_value)
  #   else
  #     credit_note.net_adjustable_amount = Amount.new(value: net_adjustable_amount_value, currency_id: 1)
  #   end
  #   # end
  #   update_credit_note_status
  # end
  #
  # def update_credit_note_status
  #   if precision_value(credit_note.net_adjustable_amount.value) == 0
  #     credit_note.update(status_id: CreditNoteStatus.id_for(:adjusted))
  #     credit_note.net_adjustable_amount.update(value: 0)
  #   elsif  credit_note.net_adjustable_amount.value < credit_note.net_receivable_amount.value
  #     credit_note.update(status_id: CreditNoteStatus.id_for(:partially_adjusted))
  #     credit_note.net_adjustable_amount.update(value: precision_value(credit_note.net_adjustable_amount.value))
  #   elsif precision_value(credit_note.net_adjustable_amount.value) == precision_value(credit_note.net_receivable_amount.value)
  #     credit_note.update(status_id: CreditNoteStatus.id_for(:unadjusted))
  #   end
  # end
end

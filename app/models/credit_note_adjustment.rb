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
#

class CreditNoteAdjustment < ApplicationRecord

  belongs_to :amount, optional: true
  belongs_to :credit_note, optional: true
  belongs_to :invoice, optional: true

  accepts_nested_attributes_for :amount
end

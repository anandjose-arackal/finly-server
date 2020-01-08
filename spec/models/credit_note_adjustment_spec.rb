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

require 'rails_helper'

RSpec.describe CreditNoteAdjustment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

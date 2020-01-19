# == Schema Information
#
# Table name: credit_note_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#

require 'rails_helper'

RSpec.describe CreditNoteStatus, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

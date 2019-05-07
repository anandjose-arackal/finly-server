# == Schema Information
#
# Table name: item_expense_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe ItemExpenseType, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: budget_groups
#
#  id                 :bigint           not null, primary key
#  company_id         :integer
#  created_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe BudgetGroup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

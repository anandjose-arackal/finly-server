# == Schema Information
#
# Table name: budget_group_criteria
#
#  id                 :bigint           not null, primary key
#  name               :string(255)
#  budget_group_id    :integer
#  ancestry           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  company_id         :integer
#  deleted_at         :datetime
#

require 'rails_helper'

RSpec.describe BudgetGroupCriterium, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

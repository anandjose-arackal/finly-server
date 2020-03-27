# == Schema Information
#
# Table name: budget_groups
#
#  id                           :bigint           not null, primary key
#  company_id                   :integer
#  created_by_user_id           :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  period_id                    :integer
#  purchase_order               :boolean
#  payment                      :boolean
#  expense                      :boolean
#  purchase_request             :boolean
#  invoice                      :boolean
#  name                         :string(255)
#  start_date                   :datetime
#  end_date                     :datetime
#  deleted_at                   :datetime
#  budget_date_type_id          :integer
#  active                       :boolean          default(TRUE)
#  calculated_before_tax_amount :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe BudgetGroup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

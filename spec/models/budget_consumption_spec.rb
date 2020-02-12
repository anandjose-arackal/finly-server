# == Schema Information
#
# Table name: budget_consumptions
#
#  id                           :bigint           not null, primary key
#  pending_amount_id            :integer
#  committed_amount_id          :integer
#  pending_payment_amount_id    :integer
#  payment_processing_amount_id :integer
#  paid_amount_id               :integer
#  budget_id                    :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  budget_amount_id             :integer
#  remaining_amount_id          :integer
#  deleted_at                   :datetime
#

require 'rails_helper'

RSpec.describe BudgetConsumption, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

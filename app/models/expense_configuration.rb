# == Schema Information
#
# Table name: expense_configurations
#
#  id                :integer          not null, primary key
#  manual_enabled    :boolean
#  card_enabled      :boolean
#  distance_enabled  :boolean
#  time_enabled      :boolean
#  per_diem_enabled  :boolean
#  configurable_id   :integer          not null
#  configurable_type :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ExpenseConfiguration < ActiveRecord::Base
  belongs_to :configurable, polymorphic: true

end

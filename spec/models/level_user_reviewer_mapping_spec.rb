# == Schema Information
#
# Table name: level_user_reviewer_mappings
#
#  id           :integer          not null, primary key
#  level_id     :integer
#  user_id      :integer
#  reviewer_id  :integer
#  policy_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  threshold    :decimal(20, 5)
#  exception    :boolean          default(TRUE)
#  wo_exception :boolean          default(TRUE)
#

require 'rails_helper'

RSpec.describe LevelUserReviewerMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

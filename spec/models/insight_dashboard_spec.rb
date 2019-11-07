# == Schema Information
#
# Table name: insight_dashboards
#
#  id            :bigint           not null
#  uuid          :string(36)       not null, primary key
#  company_id    :integer
#  user_id       :integer
#  policy_id     :integer
#  user_role_id  :integer
#  app           :string(255)
#  dashboard     :string(255)      not null
#  name          :string(255)
#  admin_user_id :integer
#  deleted_at    :datetime
#  active        :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe InsightDashboard, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

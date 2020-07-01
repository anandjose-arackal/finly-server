# == Schema Information
#
# Table name: insight_dashboards
#
#  id                     :bigint           not null
#  uuid                   :string(36)       not null, primary key
#  company_id             :integer
#  user_id                :integer
#  policy_id              :integer
#  user_role_id           :integer
#  application            :string(255)
#  dashboard              :integer          not null
#  name                   :string(255)
#  admin_user_id          :integer
#  deleted_at             :datetime
#  active                 :boolean          default(TRUE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  can_filter_date        :boolean          default(TRUE)
#  description            :text(65535)
#  priority               :integer          default(1), not null
#  can_filter_policy      :boolean          default(FALSE)
#  can_filter_department  :boolean          default(FALSE)
#  can_filter_location    :boolean          default(FALSE)
#  can_filter_cost_center :boolean          default(FALSE)
#  can_filter_category    :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe InsightDashboard, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

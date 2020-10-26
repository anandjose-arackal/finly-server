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
#  application            :string(255)      not null
#  dashboard              :integer          not null
#  name                   :string(255)
#  description            :text(65535)
#  app                    :string(255)
#  admin_user_id          :integer
#  priority               :integer          default(1)
#  deleted_at             :datetime
#  active                 :boolean          default(TRUE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  can_filter_date        :boolean
#  can_filter_policy      :boolean          default(FALSE)
#  can_filter_department  :boolean          default(FALSE)
#  can_filter_location    :boolean          default(FALSE)
#  can_filter_cost_center :boolean          default(FALSE)
#  can_filter_category    :boolean          default(FALSE)
#

class InsightDashboard < ApplicationRecord
  include UUIDHelper, SoftDeletable
  include EventProducer

  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :policy, optional: true
  belongs_to :user_role, optional: true
  belongs_to :admin_user, optional: true

  validates :name, presence: true
  validates :dashboard, presence: true
  validates :application, presence: true

  default_scope {order(priority: :desc).exclude_deleted}

  def as_json(options = {})
    {
        id: id,
        name: name,
        description: description
    }
  end

  FILTERS = [:can_filter_date, :can_filter_policy, :can_filter_department,
             :can_filter_location, :can_filter_cost_center, :can_filter_category]

  def filter_config
    config = {}
    FILTERS.each do |key|
      config[key] = !!self.send(key)
    end
    config
  end
end

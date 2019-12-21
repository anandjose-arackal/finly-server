# == Schema Information
#
# Table name: insight_dashboards
#
#  id              :bigint           not null
#  uuid            :string(36)       not null, primary key
#  company_id      :integer
#  user_id         :integer
#  policy_id       :integer
#  user_role_id    :integer
#  application     :string(255)
#  dashboard       :integer          not null
#  name            :string(255)
#  admin_user_id   :integer
#  deleted_at      :datetime
#  active          :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  can_filter_from :boolean          default(TRUE)
#  can_filter_to   :boolean          default(TRUE)
#  description     :text(65535)
#  priority        :integer          default(1), not null
#

class InsightDashboard < ApplicationRecord
  include UUIDHelper, SoftDeletable

  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :policy, optional: true
  belongs_to :user_role, optional: true
  belongs_to :admin_user, optional: true

  resolver Insights::Resolver

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

  FILTERS = [:can_filter_from, :can_filter_to]

  def filter_config
    config = {}
    FILTERS.each do |key|
      config[key] = !!self.send(key)
    end
    config
  end
end

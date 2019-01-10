# == Schema Information
#
# Table name: auto_sync_configs
#
#  id                       :integer          not null, primary key
#  company_id               :integer
#  auto_sync_config_type_id :integer
#  categories_sync          :boolean          default(FALSE)
#  company_tags_sync        :boolean          default(FALSE)
#  external_users_sync      :boolean          default(FALSE)
#  reports_sync             :boolean          default(FALSE)
#  period_id                :integer
#  enabled                  :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class AutoSyncConfig < ApplicationRecord

  belongs_to :company, optional: true
  belongs_to :auto_sync_config_type, optional: true
  belongs_to :period, optional: true


  validates :company, presence: true
  validates :periods, presence: true
end

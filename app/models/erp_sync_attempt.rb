# == Schema Information
#
# Table name: erp_sync_attempts
#
#  id           :bigint           not null, primary key
#  record_id    :integer          not null
#  record_type  :string(255)      not null
#  status_id    :integer          not null
#  company_id   :integer          not null
#  macro_id     :integer
#  macro_job_id :integer
#  message      :text(65535)
#  reference_id :text(65535)
#  attempted_at :datetime         not null
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ErpSyncAttempt < ApplicationRecord
  belongs_to :macro, optional: true
  belongs_to :record, polymorphic: true
  belongs_to :status, class_name: 'ErpSyncStatus'
  belongs_to :company

  serialize :reference_id, JSON

  default_scope {order(created_at: :desc)}

  def self.setup_migration(model)
    ActiveRecord::Migration.add_column model.table_name, :erp_sync_status_id, :integer, references: 'erp_sync_statuses', index: true, foreign_key: true unless model.has_attribute?(:erp_sync_status_id)
    ActiveRecord::Migration.add_column model.table_name, :erp_sync_message, :string unless model.has_attribute?(:erp_sync_message)
    ActiveRecord::Migration.add_column model.table_name, :erp_sync_reference_id, :string, index: true unless model.has_attribute?(:erp_sync_reference_id)
    ActiveRecord::Migration.add_column model.table_name, :erp_sync_attempts_count, :integer, index: true, default: 0 unless model.has_attribute?(:erp_sync_attempts_count)
    ActiveRecord::Migration.add_column model.table_name, :erp_sync_attempted_at, :datetime, index: true unless model.has_attribute?(:erp_sync_attempted_at)
  end

end

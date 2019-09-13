# == Schema Information
#
# Table name: event_workflows
#
#  id                :bigint           not null, primary key
#  model_class       :string(255)      not null
#  trigger_type      :string(255)      not null
#  event_key         :string(255)
#  personal          :boolean          default(TRUE)
#  user_id           :integer          not null
#  company_id        :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string(255)      not null
#  description       :text(65535)      not null
#  conditions        :text(65535)
#  event_schedule_id :integer
#

class TaskWorkflow < ApplicationRecord
  include UUIDHelper

  has_many :file_manager_actions, class_name: 'TaskFileManagerAction'

  serialize :conditions, JSON

  belongs_to :user
  belongs_to :company
  belongs_to :task_schedule

  enum trigger_type: {schedule: 1, event: 2}

  resolver TaskManager::Workflows::Policy::Scope
end

# == Schema Information
#
# Table name: task_workflows
#
#  id               :bigint           not null
#  model_class      :string(255)      not null
#  trigger_type     :string(255)      not null
#  event_key        :string(255)
#  personal         :boolean          default(TRUE)
#  user_id          :integer          not null
#  company_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  name             :string(255)      not null
#  description      :text(65535)      not null
#  conditions       :text(65535)
#  task_schedule_id :integer
#  uuid             :string(36)       not null, primary key
#

class TaskWorkflow < ApplicationRecord
  include EventProducer
  include UUIDHelper

  event_channel 'task_workflow'
  serialize :conditions, JSON

  has_many :file_manager_actions, class_name: 'TaskFileManagerAction'
  belongs_to :user
  belongs_to :company
  belongs_to :task_schedule

  enum trigger_type: {schedule: 1, event: 2}

  scope :with_event, -> (event) {where event_key: event}

  # Functions required by API runner
  def document
    @document ||= Object.const_get(model_class)
  end

  def user_roles(*list)
    @user_roles = list if list.present?
    @user_roles ||= []
  end

  def filters
    TaskManager::Workflow::Condition.new(conditions).to_ransack
    # Todo convert conditions to ransack
  end

  def actions
    # Generate actions list from database
  end

  def input
  end

  def payload_validations
  end

  def input_validations
  end

  def pre_processes
  end

  def post_processes
  end

  def success_processes
  end

  def failed_processes
  end
end

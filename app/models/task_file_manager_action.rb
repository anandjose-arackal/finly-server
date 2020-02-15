# == Schema Information
#
# Table name: task_file_manager_actions
#
#  id                 :bigint           not null, primary key
#  export_template_id :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_workflow_id  :integer          not null
#  uuid               :string(36)
#  deleted_at         :datetime
#

class TaskFileManagerAction < ApplicationRecord
  belongs_to :event_workflow
  belongs_to :export_template
end

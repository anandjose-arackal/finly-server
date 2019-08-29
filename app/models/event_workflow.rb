# == Schema Information
#
# Table name: event_workflows
#
#  id           :bigint           not null, primary key
#  model_class  :string(255)      not null
#  trigger_type :string(255)      not null
#  request_key  :string(255)
#  personal     :boolean          default(TRUE)
#  user_id      :integer          not null
#  company_id   :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name         :string(255)      not null
#  description  :text(65535)      not null
#

class EventWorkflow < ApplicationRecord
  has_many :file_manager_actions, class_name: 'EventFileManagerAction'

  belongs_to :user
  belongs_to :company
end

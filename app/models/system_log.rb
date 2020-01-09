# == Schema Information
#
# Table name: system_logs
#
#  id                :integer          not null, primary key
#  log_resource_id   :integer          not null
#  log_resource_type :string(255)      not null
#  type_id           :integer          not null
#  value             :text(65535)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SystemLog < ApplicationRecord
  belongs_to :log_resource, optional: true, polymorphic: true
  belongs_to :type, optional: true, class_name: 'SystemMessageType'

  scope :errors, -> {where type_id: SystemMessageType.id_for(:error)}
  scope :info, -> {where type_id: SystemMessageType.id_for(:info)}
  scope :success, -> {where type_id: SystemMessageType.id_for(:success)}

end

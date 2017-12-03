class SystemLog < ActiveRecord::Base
  belongs_to :log_resource, polymorphic: true
  belongs_to :type, class_name: 'SystemMessageType'

  scope :errors, -> {where type_id: SystemMessageType.id_for(:error)}
  scope :info, -> {where type_id: SystemMessageType.id_for(:info)}
  scope :success, -> {where type_id: SystemMessageType.id_for(:success)}

end

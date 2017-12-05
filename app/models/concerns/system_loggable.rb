module SystemLoggable
  extend ActiveSupport::Concern

  included do
    has_many :system_logs, as: :log_resource
  end

  def log_state(type, value)
    raise 'Log value cannot be blank' if value.blank? or type.blank?

    unless value.is_a?(Array)
      value = [value]
    end
    value.each do |val|
      if self.persisted?
        self.system_logs.create type_id: SystemMessageType.id_for(type), value: val
      else
        self.system_logs.new type_id: SystemMessageType.id_for(type), value: val
      end
    end
  end

end
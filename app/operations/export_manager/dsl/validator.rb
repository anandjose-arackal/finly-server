module ExportManager::DSL::Validator
  extend ActiveSupport::Concern

  included do
    class_attr :validations, default: []
  end

  class_methods do
    def validate(validation)
      validations << validation
    end
  end

  def valid?
    clear_messages
    self.class.validations.each do |validation|
      if validation.is_a?(Symbol)
        self.send(validation)
      else
        validation.call(user, params)
      end
    end
    !has_errors?
  end
end
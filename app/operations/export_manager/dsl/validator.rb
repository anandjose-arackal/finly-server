module ExportManager::DSL::Validator
  extend ActiveSupport::Concern

  included do
    class_attr :validations, default: []
  end

  class_methods do
    def validate(validation)
      # validations([]) if validations.nil?
      validations << validation
    end

    def valid_company?(user, params)
      scope = company_scope[Rails.env]
      return true unless scope.present?
      return false if scope[:id].to_s != user.company_id.to_s
      return false if scope[:name] != user.company.name
      true
    end
  end

  def valid?
    clear_messages
    # Validate acceptance condition
    unless self.class.accept?(user, params)
      add_message :error, 'The selected handler cannot handle this request'
      return false
    end

    # Validate company scope
    unless self.class.valid_company?(user, params)
      add_message :error, 'The request cannot be processed'
      return false
    end

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
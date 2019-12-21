class LogSanitizer

  def self.sanitize(params)
    result = {}
    params.each do |key, value|
      result_value = value
      if [ActiveSupport::HashWithIndifferentAccess.name,
          ActionController::Parameters.name,
          Hash.name,
          HashWithIndifferentAccess.name].include?(value.class.name)
        result_value = sanitize(value)
      elsif value.respond_to?(:each)
        values = []
        value.each do |v|
          values << sanitize(v)
        end
        result_value = values
      elsif value.class.name == String.name and value.start_with?('data:text')
        result_value = "<FILTERED>"
        # Skip
      elsif key == 'password' or key == :password
        result_value = "<FILTERED>"
        # Skip
      elsif key == 'password_confirmation' or key == :password_confirmation
        result_value = "<FILTERED>"
        # Skip
      else
        result_value = value
      end
      result[key] = result_value
    end
    result
  end

end
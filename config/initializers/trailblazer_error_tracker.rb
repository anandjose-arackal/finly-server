module TrailblazerErrorTracker
  def errors
    model_errors = self['model']&.errors&.messages || {}
    contract_errors = self['contract.default']&.errors&.messages || {}
    policy_errors = self['result.policy.default']&.errors || {}
    roles_auth_errors = {}
    if self['result.authorization']&.failure?
      roles_auth_errors.merge!(base: 'You cannot perform the following action')
    end
    if self['result.policy.default'].present? and self['result.policy.default']['message'] == 'Breach'
      policy_errors.merge!({base: 'You cannot perform the following action'})
    end
    general_errors = self['result.operation.errors'] || {}
    model_errors.merge(contract_errors).merge(general_errors).merge(policy_errors).merge(roles_auth_errors)
  end

  def messages(type = nil)
    unless type
      meta_keys = errors.keys.filter {|key| key != "base" || key != :base}
      base_keys = errors.keys.filter {|key| key == "base" || key == :base}

      all_err_messages = []

      meta_keys.each do |key|
        prepend_value = key.to_s.humanize.gsub(".", " > ")

        if errors[key].is_a?(Array)
          error_messages = errors[key].map {|m| prepend_value + " " + m.to_s}
          all_err_messages.push(error_messages)
        elsif errors[key].is_a?(String)
          error_messages = prepend_value + " " + errors[key]
          all_err_messages.push(error_messages)
        end
      end

      all_err_messages.push(errors[:base])
      all_err_messages.push(errors['base'])

      messages = {
          success: (messages(:success)&.values&.flatten || []),
          # errors: (messages(:errors)&.values&.flatten || []),
          # errors: errors&.values&.flatten || [],
          errors: all_err_messages.flatten.compact,
          # errors_meta: (messages(:errors) || [])
          errors_meta: errors || {}
      }
      return messages
    end
    self["result.operation.#{type}"]
  end

  def created?
    success? && self["model.action"] == :new
  end

  def not_found?
    failure? && self["result.model"] && self["result.model"]&.failure?
  end

  def unauthorized?
    failure? && (self["result.policy.default"]&.failure? || self['result.authorization']&.failure?)
  end
end
Trailblazer::Operation::Result.include TrailblazerErrorTracker
Trailblazer::Operation::Railway::Result.include TrailblazerErrorTracker
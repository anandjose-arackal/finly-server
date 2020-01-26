module Transactions::Result::ErrorBuilder
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
      messages = {
          success: (messages(:success)&.values&.flatten || []),
          # errors: (messages(:errors)&.values&.flatten || []),
          errors: errors&.values&.flatten || [],
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
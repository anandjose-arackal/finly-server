module TrailblazerErrorTracker
  def errors
    model_errors = self['model']&.errors&.messages || {}
    contract_errors = self['contract.default']&.errors&.messages || {}
    policy_errors = self['result.policy.default']&.errors || {}
    if self['result.policy.default'].present? and self['result.policy.default']['message'] == 'Breach'
      policy_errors.merge!({base: 'You cannot perform the following action'})
    end
    general_errors = self['result.operation.errors'] || {}
    model_errors.merge(contract_errors).merge(general_errors).merge(policy_errors)
  end

  def messages(type)
    self["result.operation.#{type}"]
  end
end
Trailblazer::Operation::Result.include TrailblazerErrorTracker
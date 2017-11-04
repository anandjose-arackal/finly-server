module PostOperationExecution
  extend ActiveSupport::Concern

  included do
    serialize :post_operation_payload
  end

  def execute_post_operation(success)
    return unless self.post_operation.present?
    Object.const_get(post_operation).(self, post_operation_payload, success)
  end

end
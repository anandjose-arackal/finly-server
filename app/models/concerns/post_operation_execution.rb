module PostOperationExecution
  extend ActiveSupport::Concern

  included do
    serialize :post_operation_payload
  end

  class_methods do
    def execute_post_operation(success)
      return unless self.post_operation.present?
      event_class_name = post_operation
      on_completion_payload = post_operation_payload
      Object.const_get(event_class_name).(self, on_completion_payload, success)
    end
  end

end
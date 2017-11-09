module PostOperationExecution
  extend ActiveSupport::Concern

  included do
    has_many :post_operation_actions, as: :post_operatable
  end

  def execute_post_operation(success, options={})
    return unless self.post_operation_actions.present?
    self.post_operation_actions.each do |op|
      payload = (options[:post_operation_payload] or op.payload)
      Object.const_get(op.operation).(self, payload, success)
    end
  end

end
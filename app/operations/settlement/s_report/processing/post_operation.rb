class Settlement::SReport::Processing::PostOperation < FinlyPostOperation
  attr_accessor :payment_order

  def pre_validate
    if object.blank?
      add_message :error, 'Payment Order not found'
      return
    end
  end

  def init
    self.payment_order = object
    self.report_processor_group = ReportProcessorGroup.with_payment_order_id(self.payment_order.id)&.first
  end

  def validate
    if self.report_processor_group.blank?
      add_message :error, 'Batch not found'
      return
    end
  end

  def process
    has_success = false
    has_failure = false
    self.report_processor_group.mappings.each do |mapping|
      if mapping.payment.completed?
        has_success = true
        # mapping.update()
      elsif mapping.payment.failed?
        has_failure = true
      end
    end
  end

end
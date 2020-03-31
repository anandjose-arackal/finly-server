class Personalizer::Adapters::Company2::Report2::Violation2::PostProcess < Personalizer::Adapters::Base

  attr_accessor :report, :validate_keys, :warning_messages

  def init
    self.report = op_instance.report
    self.warning_messages = op_instance.warning_messages
    self.validate_keys = %w(
                       tax_rate_id
                       gst_type_id
                       state_of_expense_id
                       hsn_sac
                       merchant_bill_no
                       gstin_location_attributes.gstin
                       gstin_location_attributes.state_id
                     )
  end

  def process
    # self.report.expenses.each do |expense|
    #   if expense.category.gst_applicable? && expense.manual_expense?
    #     errors = []
    #     if expense.tax_rate_id.blank?
    #       errors += ["tax rate"]
    #     end
    #     if expense.gst_type_id.blank?
    #       errors += ["GST type"]
    #     end
    #     if expense.state_of_expense_id.blank?
    #       errors += ["State of expense"]
    #     end
    #     if expense.hsn_sac.blank?
    #       errors += ["HSN/SAC"]
    #     end
    #     if expense.merchant_bill_no.blank?
    #       errors += ["Merchant bill number"]
    #     end
    #     if expense.gstin_location&.gstin.blank?
    #       errors += ["GSTIN"]
    #     end
    #     if expense.gstin_location&.state_id.blank?
    #       errors += ["Merchant state"]
    #     end
    #     if errors.present?
    #       self.warning_messages[expense.id]["expense_blocking"] << {type: "GST", message: "The following expense fields: #{errors.to_sentence} cannot be blank"}
    #     end
    #   end
    # end
  end

end
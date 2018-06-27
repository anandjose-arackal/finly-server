class Personalizer::Adapters::Company104::Report104::Approve104::PreProcess < Personalizer::Adapters::Base
  attr_accessor :report

  # For Expense Verification user, verify if tally party name has been entered for all expenses with GST and TDS. If not throw an error

  def init
    self.report = self.op_instance.report
  end

  def validate
    # Check if user is Expense Verification user
    return unless user.id == 10842 and user.company_id == 104
    if self.report.blank?
      return
    end
    self.report.expenses.each do |expense|
      next unless expense.has_tds? or expense.has_gst?
      # Ensure all expenses with GST and TDS have Tally Party Name entered
      party_account_name = expense.custom_fields.with_field_key('tally_party_name')&.first&.value&.value
      if party_account_name.blank?
        add_message :error, "Please fill in the tally party account name for #{expense.merchant_name}"
      end
    end
  end

end

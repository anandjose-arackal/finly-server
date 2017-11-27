class Personalizer::Adapters::Company2::Report2::Violation2::PostProcess < Personalizer::Adapters::Base
  attr_accessor :report

  def init
    message = 'Expenses older than 15 days require approval from Director'
    op_instance.report.expenses.each do |expense|
      op_instance.warning_messages[expense.id]['expense_warning'] << {type: 'date', message: message}
    end
  end

end
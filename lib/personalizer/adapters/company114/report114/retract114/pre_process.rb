class Personalizer::Adapters::Company114::Report114::Retract114::PreProcess < Personalizer::Adapters::Base
  attr_accessor :report

  # Ensure that if it is approved by all managers, the report cannot be retracted

  def init
    self.report = self.op_instance.report
  end

  def validate
    if self.report.controlling_user_role_id == UserRole.id_for(:finance_manager)
      add_message :error, 'The report cannot be retracted at the moment'
      return
    end
  end

end

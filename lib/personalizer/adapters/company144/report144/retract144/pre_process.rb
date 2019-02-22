class Personalizer::Adapters::Company144::Report144::Retract144::PreProcess < Personalizer::Adapters::Base
  attr_accessor :report

  # Ensure that if it is approved by all managers, the report cannot be retracted

  def validate
    add_message :error, 'The report cannot be retracted at the moment'
  end

end

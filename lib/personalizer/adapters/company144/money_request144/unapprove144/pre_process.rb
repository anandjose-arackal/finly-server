class Personalizer::Adapters::Company144::MoneyRequest144::Unapprove144::PreProcess < Personalizer::Adapters::Base
  attr_accessor :report

  # Ensure that if it is approved by all managers, the report cannot be retracted

  def validate
    add_message :error, 'The request cannot be unapproved at the moment'
  end

end

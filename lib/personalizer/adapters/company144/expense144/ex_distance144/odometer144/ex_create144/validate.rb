class Personalizer::Adapters::Company144::Expense144::ExDistance144::Odometer144::ExCreate144::Validate < Personalizer::Adapters::Base
  attr_accessor :report

  # Do not allow odometer expense to be created

  def validate
    add_message :error, 'Odometer expense has not been enabled for your account'
  end

end

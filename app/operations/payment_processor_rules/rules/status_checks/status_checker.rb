PaymentProcessorRules::Checker.new 'StatusChecker' do

  section 'on credit initiate' do

  end

  section 'on hitting bank account adapter' do

  end

  # this section will basically check if the payment is stuck in pending, or any other
  # irregular state and then triggers mailer or something else
  section 'on completion of payment' do

  end
end
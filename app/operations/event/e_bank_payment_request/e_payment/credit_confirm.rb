# this will send an SMS and a mailer to the users who are at the receiving end of this payment
# ideally triggered at the time of payment credit

class Event::EBankPaymentRequest::EPayment::CreditConfirm < Event::EBankPaymentRequest::Base

  attr_accessor :payment, :receiving_user

  def action_name
    "Payment Received"
  end

  def init
    self.payment = params[:payment]
    self.receiving_user = payment.receiving_user
  end

  def affected_users
    [receiving_user]
  end

  def sms_affected_users
    [receiving_user]
  end

  def mailer_subject(user)
    "Confirmation of Credit of amount #{payment.amount_value}"
  end

  def mailer_body(user)
    "You have received a credit of ₹#{payment.amount_value} via #{payment.payment_mode} from #{receiving_user.company.name} in your bank account: #{payment.receiving_account.account_number}. <br/><br/>
    The transaction number for your reference is: #{payment.reference_resource.bank_reference_number}"
  end

  def sms_message
    "You have received a credit of ₹#{payment.amount_value} via #{payment.payment_mode} from #{receiving_user.company.name} in your bank account: #{payment.receiving_account.account_number}. The transaction number for your reference is: #{payment.reference_resource.bank_reference_number}"
  end

end
# this will send an SMS and a mailer to the users who are at the receiving end of this payment
# ideally triggered at the time of payment credit

class Event::EBankPaymentRequest::EPayment::CreditConfirm < Event::EBankPaymentRequest::EPayment::Base

  attr_accessor :payment, :receiving_user

  def event_id
    NotifierType.id_for(:bank_payment_request_credit_confirm)
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment].blank?
      add_message :error, 'Payment not found'
      return
    end
    unless params[:payment].is_a?(::Payment)
      add_message :error, 'Error loading Payment'
    end
  end

  def action_name
    "Payment Received"
  end

  def init
    self.payment = params[:payment]
    self.receiving_user = payment.receiving_user
  end

  def validate
    if payment.blank?
      add_message :error, "Payment not found"
    end
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
    The transaction number for your reference is: #{payment.utr}"
  end

  def sms_message
    "You have received Rs.#{payment.amount_value} from #{receiving_user.company.name} in your A/c: XX#{payment.receiving_account.account_number.last(4)} Ref no:#{payment.utr} via Finly Spend Mgmt"
  end



end
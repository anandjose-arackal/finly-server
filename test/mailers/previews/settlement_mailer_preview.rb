Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

require "minitest/unit"
require "mocha/mini_test"

# Preview all emails at http://localhost:3000/rails/mailers/settlement_mailer
class SettlementMailerPreview < ActionMailer::Preview

  # http://localhost:3000/rails/mailers/settlement_mailer/add_cash
  def add_cash
    amount = Amount.new
    payment = Payment.new(id: 10000)
    amount.stubs(:value).returns(100)
    payment.stubs(:amount => amount, :initiating_user => User.first)
    event = Event::ESettlement::AddCashAdvance.new(User.second, {payment: payment})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    SettlementMailer.send_mail(Event::ESettlement::Base::MailerPresenter.new(event.user, {payment: event.payment, subject: subject, body: body, action_name: "Cash Advance Added to Cash on Hand", payment_note: "Use the money well, Paduwan"}))
  end

  # http://localhost:3000/rails/mailers/settlement_mailer/debt_clearance
  def debt_clearance
    amount = Amount.new
    payment = Payment.new(id: 10000)
    amount.stubs(:value).returns(100)
    payment.stubs(:amount => amount, :initiating_user => User.first)
    event = Event::ESettlement::AddDebtClearance.new(User.second, {payment: payment})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    SettlementMailer.send_mail(Event::ESettlement::Base::MailerPresenter.new(event.user, {payment: event.payment, subject: subject, body: body, action_name: "Cash Deducted from Cash on Hand", payment_note: "Gotta get that money back"}))
  end

    # http://localhost:3000/rails/mailers/settlement_mailer/reimburse
  def reimburse
    amount_payment = Amount.new
    cash_on_hand_deduction_amount = Amount.new
    payment = Payment.new(id: 10000)
    cash_on_hand_deduction = Payment.new(id: 100001)
    amount_payment.stubs(:value).returns(100)
    cash_on_hand_deduction_amount.stubs(:value).returns(200)
    payment.stubs(:amount => amount_payment, :initiating_user => User.first, :reimbursed_reports => [Report.first, Report.second, Report.third])
    cash_on_hand_deduction.stubs(:amount => cash_on_hand_deduction_amount, :initiating_user => User.first, :cash_in_hand_settled_reports =>[Report.first, Report.second, Report.third] )
    event = Event::ESettlement::AddSettlement.new(User.second, {payment: payment, cash_in_hand_deduction: cash_on_hand_deduction})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    SettlementMailer.send_mail(Event::ESettlement::Base::MailerPresenter.new(event.user, {payment: event.payment, subject: subject, body: body, action_name: "New Reports Settled", payment_note: "Luke, I am your father"}))
  end

end

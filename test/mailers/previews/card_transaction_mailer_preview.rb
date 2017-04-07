Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3001/rails/mailers/card_transaction_mailer
require "minitest/unit"
require "mocha/mini_test"

class CardTransactionMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/card_transaction_mailer/new
  def new_atm_withdrawal
    u = User.find(4)
    transaction = u.card_transactions.atm_withdrawals.first
    event = Event::ECard::ETransaction::Create.new(u, transaction: transaction)
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    CardTransactionMailer.send_mail(Event::ECard::ETransaction::Base::MailerPresenter.new(u, {transaction: transaction, body: body, subject: subject, action_name: "New Card Transaction"}))
  end

  def new_card_transaction
    u = User.first
    transaction = u.card_transactions.find_by(id: 8)
    # card_expense = CardExpense.first
    # transaction.stubs(:expense?).returns(true)
    # transaction.stubs(:card_expense).returns(card_expense)
    # transaction.stubs(:billing_amount).returns(Amount.first)
    event = Event::ECard::ETransaction::Create.new(u, transaction: transaction)
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    CardTransactionMailer.send_mail(Event::ECard::ETransaction::Base::MailerPresenter.new(u, {transaction: transaction, body: body, subject: subject, action_name: "New Card Transaction"}))
  end
end
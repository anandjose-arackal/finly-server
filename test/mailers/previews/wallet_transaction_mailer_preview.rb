Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

class WalletTransactionMailerPreview < ActionMailer::Preview

  # http://localhost:3000/rails/mailers/wallet_transaction_mailer/credit

  def credit

  end

  def debit

  end
end
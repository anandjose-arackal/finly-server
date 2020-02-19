class Docs::UtilityBills::Subscriptions::Mailers::Base < Notifier::Mailer

  assign :tables do |user, params|
    tables = []
    tables.push(Docs::UtilityBills::Subscriptions::Mailers::TableBuilder.(params[:record]))
  end

end
class Docs::UtilityBills::Subscriptions::Mailers::Base < Notifier::Mailer

  assign :tables do |user, params|
    tables = []
    tables.push(Docs::UtilityBills::Subscriptions::Mailers::TableBuilder.(params[:record]))
  end

  assign :hero_bg_icon, "icon_bbps_biller_subscription"

end
class Docs::UtilityBills::Bills::Mailers::Base < Notifier::Mailer
  assign :tables do |user, params|
    tables = []
    tables.push(Docs::UtilityBills::Bills::Mailers::TableBuilder.(params[:record]))
  end

  assign :hero_bg_icon, "icon_bbps_bill"
end
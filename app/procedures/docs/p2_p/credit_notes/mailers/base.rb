class Docs::P2P::CreditNotes::Mailers::Base < Notifier::Mailer
  assign :tables do |user, params|
    tables = []
    tables.push(Docs::P2P::CreditNotes::Mailers::TableBuilder.(params[:record]))
  end
end
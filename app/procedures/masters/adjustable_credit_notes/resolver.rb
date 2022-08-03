class Masters::AdjustableCreditNotes::Resolver < Masters::Vendors::Resolver

  entity CreditNote

  def load(params)
    user.company.credit_notes.filter_adjustables
  end

end
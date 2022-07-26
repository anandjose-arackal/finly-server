class Masters::AdvanceAmountStatuses::Resolver < Resolver::API

  entity AdvanceAmountStatus

  def load(params)
    excluded_invoice_ids = []

    AdvanceAmountStatus.where.not(id: excluded_invoice_ids)
  end

end
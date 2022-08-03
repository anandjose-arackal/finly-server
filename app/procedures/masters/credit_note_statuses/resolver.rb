class Masters::CreditNoteStatuses::Resolver < Resolver::API

  entity CreditNoteStatus

  def load(params)
    excluded_status_ids = []

    CreditNoteStatus.where.not(id: excluded_status_ids)
  end

end
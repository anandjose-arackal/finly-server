class Masters::CreditNoteItemTypes::Resolver < Resolver::API

  entity CreditNoteItemType

  def load(params)
    included_type_ids = [
      CreditNoteItemType.id_for(:qty_change),
      CreditNoteItemType.id_for(:price_drop),
      CreditNoteItemType.id_for(:gst_change)
    ]

    CreditNoteItemType.where(id: included_type_ids)
  end

end
recent_documents = @op["recent_documents"]

json.recent_documents do
  json.array! recent_documents do |item|
    json.extract! item, :id
    json.created_at item.created_at.strftime("%b %d, %Y")
    json.created_at_time item.created_at.strftime("%I:%M%p")
    json.type item.class.name
		json.user do
      if item.is_a?(Invoice)
        json.id item&.created_by&.id
        json.name item&.created_by&.name
        json.email item&.created_by&.email
      elsif item.is_a?(Payment)

      else
        json.id item&.user&.id
        json.name item&.user&.name
        json.email item&.user&.email
      end
    end

		if item.is_a?(Invoice)
      json.invoice_details do
        json.amount item.balance_due&.value.to_f.round(2)
        json.inv_number item.invoice_number
        json.forms_enabled item.forms_enabled
        json.base_currency item.get_base_currency

        json.status do
          json.id item.invoice_status&.id
          json.name item.invoice_status&.name
        end
        if item.payments.processed.first.present?
          payment = item.payments.processed.first
          json.utr  payment.utr
        end
        json.due_date item.due_date&.strftime("%b %d, %Y")
      end
		end
  end
end
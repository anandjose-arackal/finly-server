json.approved_at record.approved_at&.strftime("%d-%m-%Y")
json.paid_payment_id record.payments.completed.first&.id

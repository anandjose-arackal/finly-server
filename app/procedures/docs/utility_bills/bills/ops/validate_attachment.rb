class Docs::UtilityBills::Bills::Ops::ValidateAttachment < Transactions::API
  step Model(BbpsBill, :find_by)
  step :validate_presense_of_attachments

  def validate_presense_of_attachments(options, model:, current_user:, **)
    return true unless BbpsInvoiceAttachmentMandatoryToggle.new(current_user).enabled?
    return true if model.attachments.present?

    add_message options, :error, :attachments, 'missing'

    return false
  end
end
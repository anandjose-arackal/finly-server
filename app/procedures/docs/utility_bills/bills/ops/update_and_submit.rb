class Docs::UtilityBills::Bills::Ops::UpdateAndSubmit < Transactions::API

  step Model(BbpsBill, :find_by)
  step :update
  step :validate_presense_of_attachments
  step :submit

  def update(options, params:, current_user:, **)
    op = Docs::UtilityBills::Bills::Ops::Update.(params: params, current_user: current_user)

    op.messages.each do |key, val|
      next if key == :errors_meta
      add_message options, key, :base, val
    end

    op.success?
  end

  def validate_presense_of_attachments(options, model:, current_user:, **)
    return true unless BbpsInvoiceAttachmentMandatoryToggle.new(current_user).enabled?
    return true if model.attachments.present?

    add_message options, :error, :attachments, 'missing'
    return false
  end

  def submit(options, params:, current_user:, **)
    params[:aasm_event] = :submit
    op = Docs::UtilityBills::Bills::Ops::Review.(params: params, current_user: current_user)

    op.messages.each do |key, val|
      next if key == :errors_meta
      add_message options, key, :base, val
    end

    op.success?
  end
end
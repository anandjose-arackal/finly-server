class Event::EBankPaymentRequest::Base < Event::SetNotifier

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:bank_payment_request].blank?
      add_message :error, 'Report not found'
      return
    end
    unless params[:bank_payment_request].is_a?(::Report)
      add_message :error, 'Error loading report'
    end
  end

  def init

  end
end
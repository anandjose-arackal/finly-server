class Personalizer::Adapters::Company2::MoneyRequest2::Submit2::SendNotification < BackgroundOperation
  attr_accessor :money_request

  def init
    self.money_request = MoneyRequest.find_by_id(params[:money_request_id])
  end

  def validate
    if self.money_request.blank?
      return
    end
  end

  def process
    process_push_notifications
    process_sms
  end

  def process_push_notifications
    message = "#{self.money_request.user.name} has submitted the Money Request: #{self.money_request.name}"
    view = 'admin'
    event_id = NotifierType.id_for(:money_request_submit)
    users_to_notify = user.company.admins - [self.money_request.user, self.money_request.controlling_user]
    users_to_notify.each do |user|
      GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
    end
  end

  def process_sms
    message = "Finly: #{self.money_request.user.name} has submitted the Money Request: #{self.money_request.name} for an amount of #{self.money_request.submitted_amount&.value&.to_s}"
    admins = user.company.admins
    admins.each do |user|
      Sms::Send.(user, {message: message, mobile_number: user.mobile_number})
    end
  end

end
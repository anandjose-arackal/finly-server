class Personalizer::Adapters::Company2::MoneyRequest2::ApproveAndForward2::SendNotification < BackgroundOperation
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
    action_user = self.money_request.tracks.last.action_user
    message = "Finly: #{action_user.name} has approved and forwarded the Money Request: #{self.money_request.name} to #{self.money_request.controlling_user&.name}"
    view = 'admin'
    event_id = NotifierType.id_for(:money_request_submit)
    users_to_notify = user.company.admins - [action_user, self.money_request.controlling_user]
    users_to_notify.each do |user|
      GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
    end
  end

  def process_sms
    action_user = self.money_request.tracks.last.action_user
    message = "Finly: #{action_user.name} has approved and forwarded the Money Request: #{self.money_request.name} for an amount of #{self.money_request.submitted_amount&.value&.to_s} to #{self.money_request.controlling_user&.name}"
    admins = user.company.admins - [action_user]
    admins.each do |user|
      Sms::Send.(user, {message: message, mobile_number: user.mobile_number})
    end
  end

end
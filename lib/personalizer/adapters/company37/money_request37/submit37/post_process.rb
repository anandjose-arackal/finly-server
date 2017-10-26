class Personalizer::Adapters::Company37::MoneyRequest37::Submit37::PostProcess < Personalizer::Adapters::Base
  attr_accessor :money_request

  def init
    self.money_request = self.op_instance.money_request
  end

  def validate
    if self.money_request.blank?
      return
    end
  end

  def process
    Personalizer::Adapters::Company37::MoneyRequest37::Submit37::SendNotification.call_async(user.id, money_request_id: self.money_request.id)
  end

end
class Personalizer::Adapters::Company109::MoneyRequest109::Submit109::PreProcess < Personalizer::Adapters::Base
  attr_accessor :money_request

  def init
    self.money_request = self.op_instance.money_request
  end

  def validate
    if self.money_request.blank?
      return
    end
    # If associated with travel_request, unless travel request booking is confirmed, money request cannot be raised
    travel_request = money_request.travel_request
    if travel_request.present? and travel_request.status_id != TravelRequestStatus.id_for(:booking_confirmed)
      add_message :error, 'You can only raise money requests travel has been confirmed'
      return
    end
  end

end

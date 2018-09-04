class Personalizer::Adapters::Company114::TravelRequest114::Create114::PostValidate < Personalizer::Adapters::Base

  def init
    if op_instance.travel_request.purpose_of_travel.blank?
      add_message :error, 'Please provide the Purpose of Travel to continue'
    end
  end

end
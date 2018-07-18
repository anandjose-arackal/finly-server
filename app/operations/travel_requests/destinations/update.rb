class TravelRequests::Destinations::Update < TravelRequests::Base
  attr_accessor :destination, :travel_request

  def init
    show_presenter = TravelRequests::Destinations::Show.(user, params)
    unless show_presenter.success?
      add_message :error, show_presenter.messages[:error]
      return
    end
    self.destination = show_presenter.destination
    self.destination.assign_attributes strong_params
  end

  def validate
    unless self.destination.valid?
      add_message :error, self.destination.errors.full_messages
    end
  end

  def process
    self.destination.save
  end

  protected

  def strong_params
    params.require(:destination).permit(:name, :map_id)
  end

end
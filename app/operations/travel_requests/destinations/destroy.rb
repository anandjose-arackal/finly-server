class TravelRequests::Destinations::Destroy < TravelRequests::Base
  attr_accessor :destination

  def init
    show_presenter = TravelRequests::Destinations::Show.(user, params)
    unless show_presenter.success?
      add_message :error, show_presenter.messages[:error]
      return
    end
    self.destination = show_presenter.destination
  end

  def validate
    unless self.destination.present?
      add_message :error, 'Destination could not be found'
      return
    end
    if self.destination.bookings.present?
      add_message :error, 'Please clear all booking requests to delete a destination'
      return
    end
  end

  def process
    unless self.destination.destroy
      add_message :error, self.destination.errors.full_messages
      return
    end
  end

end
class Dashboard::ExpenseManagement::Trips < Dashboard::ExpenseManagement::Base
  attr_accessor :trips

  def init
    # {"view"=>"personal", "menu"=>{"main"=>"trips"}, "page"=>"1", "per_page"=>"30"}
    self.trips = TravelRequests::Index.(user, params)

  end

  def success
    params[:trips] = self.trips
    Dashboard::ExpenseManagement::Trips::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::ExpenseManagement::Trips::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :trips, :counts

    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      general_filter_params = {
      }

      self.trips = apply_scope(params[:trips], params)
      self.trips = self.trips.travel_requests
      self.counts = []
      personal_travel_data = {
        type: 'personal_travel',
        data: [
          {
            title: "Booking Pending",
            count: self.trips.filter_status('booking_pending')&.count,
            total_amount: self.trips.filter_status('booking_pending').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
            filters: []
          },

          {
            title: "Processing Travel Requests",
            count: self.trips.filter_status('processing')&.count,
            total_amount: self.trips.filter_status('processing').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
            filters: []
          },

          {
            title: "Booking Confirmed",
            count: self.trips.filter_status('booking_confirmed')&.count,
            total_amount: self.trips.filter_status('booking_confirmed').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
            filters: []
          },

          {
            title: "Rejected Travel Requests",
            count: self.trips.filter_status('rejected')&.count,
            total_amount: self.trips.filter_status('rejected').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
            filters: []
          }
        ]

      }

      self.counts << personal_travel_data

    end
  end
end

class Dashboard::ExpenseManagement::Trips < Dashboard::ExpenseManagement::Base
  attr_accessor :trips

  def init
    # {"view"=>"personal", "menu"=>{"main"=>"trips"}, "page"=>"1", "per_page"=>"30"}
    params[:view] = get_relevant_view
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

      self.trips = apply_scopes(params[:trips], params)
      self.trips = self.trips.travel_requests.includes(:reports, :bookings, {policy: [:base_currency]}, {money_requests: [items: [{money_request: [:payment_mode, {destination_pocket: :base_currency}]}, {amount: [:currency]}]]})
      self.counts = []
      personal_travel_data = {
          type: 'personal_travel',
          data: [
              {
                  title: "Pending",
                  count: self.trips.filter_status('booking_pending')&.count,
                  total_amount: self.trips.filter_status('booking_pending').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
                  filters: [{filter_status: 'booking_pending'}]
              },

              {
                  title: "Processing",
                  count: self.trips.filter_status('processing')&.count,
                  total_amount: self.trips.filter_status('processing').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
                  filters: [{filter_status: 'processing'}]
              },

              {
                  title: "Confirmed",
                  count: self.trips.filter_status('booking_confirmed')&.count,
                  total_amount: self.trips.filter_status('booking_confirmed').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
                  filters: [{filter_status: 'booking_confirmed'}]
              },

              {
                  title: "Rejected",
                  count: self.trips.filter_status('rejected')&.count,
                  total_amount: self.trips.filter_status('rejected').map {|tr| tr.summary[:trip_cost].value}&.compact&.sum,
                  filters: [{filter_status: 'rejected'}]
              }
          ]

      }

      self.counts << personal_travel_data

    end
  end
end

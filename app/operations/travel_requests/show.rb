class TravelRequests::Show < TravelRequests::Base
  attr_accessor :travel_request

  def init
    requests_presenter = TravelRequests::Index.(user, params)
    unless requests_presenter.success?
      add_message :error, requests_presenter.messages[:error]
      return
    end
    self.travel_request = requests_presenter.travel_requests.find_by(id: (params[:id] || params[:travel_request_id]))
  end

  def validate
    if travel_request.blank?
      add_message :error, 'Travel Request not found'
    end
  end

  def success
    params[:travel_request] = self.travel_request
    TravelRequests::Show::ShowPresenter.new(user, params, messages)
  end

  class TravelRequests::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :travel_request, :manager_user, :travel_manager_user

    def init
      self.travel_request = params[:travel_request]
    end

    def booking_types
      BookingType.all
    end

    def destinations
      travel_request.destinations
    end

    def manager
      if self.manager_user.blank?
        self.manager_user = User::Team::Approver.(self.travel_request.user, travel_request: self.travel_request, type: :manager)
      end
      self.manager_user
    end

    def travel_manager
      if self.travel_manager_user.blank?
        self.travel_manager_user = User::Team::Approver.(self.travel_request.user, travel_request: self.travel_request, type: :travel_manager)
      end
      self.travel_manager_user
    end

    def actions
      actions = {editable: editable, destroyable: destroyable}
      controlling_user = travel_request.controlling_for_user || travel_request.controlling_user
      controlling_user_role_id = travel_request.controlling_for_user_role_id || travel_request.controlling_user_role_id
      if admin_view?
        # Take Control
        # Approve, Reject, Select Booking, Confirm Booking

      elsif travel_manager_view?
        # Add/Remove/Update booking request, options, confirmed

        # Cancel booking

        # Request selection

        # Confirm booking

      elsif manager_view?
        # Approve, Reject, Reject request
        if travel_request.processing? and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
          actions[:approve] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:reject] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Select options

        # Confirm Selection

        # Approve Selection

      elsif personal_view?
        # Submit
        if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
          actions[:submit] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Retract
        if travel_request.processing? && travel_request.user_id == user.id
          actions[:submit] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Confirm selection
        if travel_request.selection_requested? && travel_request.user_id == user.id
          actions[:confirm_selection] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      end
      case travel_request.controlling_user_role_id
      when nil
      when UserRole.id_for(:employee)
        if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
          actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      when UserRole.id_for(:manager)
      when UserRole.id_for(:travel_manager)
      end
      # todo associated_users
      if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
        actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      elsif travel_request.processing?
        if travel_request.controlling_user_id == user.id && (user.manager?)
          actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        elsif user.company_admin? && admin_view?
          actions[:take_control] = {method: "patch", type: 6, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        elsif user.employee? && self.travel_request.user_id == user.id
          actions[:retract] = {method: "patch", type: 3, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      elsif travel_request.approved?
        if travel_request.controlling_user_id == user.id && user.travel_manager?
          actions[:finish_booking] = {method: "patch", type: 7, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      elsif travel_request.booked?
        if travel_request.controlling_user_id == user.id && user.travel_manager?
          actions[:retract_booking] = {method: "patch", type: 8, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      end
      actions
    end

    def can_select_options?

    end

    def editable
      if self.travel_request.open? || self.travel_request.rejected? || self.travel_request.retracted?
        if self.travel_request.user_id == self.user.id
          return true
        end
      elsif self.travel_request.processing?
        if self.travel_request.controlling_user_id == user.id
          return true
        end
      end
      false
    end

    def destroyable
      if TravelRequestStatus.ids_for(:open, :retracted, :rejected)
        if self.travel_request.controlling_user_id == self.user.id
          return true
        end
      end
      false
    end

    def grouped_bookings(destination)
      val = {}
      destination.bookings.without_parent.each do |booking|
        if val[booking.booking_type&.name].nil?
          val[booking.booking_type&.name] = []
        end
        val[booking.booking_type&.name] << booking
      end
      val
    end

  end

end
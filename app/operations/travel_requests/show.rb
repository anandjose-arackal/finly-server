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
        # todo Take Control

        # todo Approve, Reject, Select Booking, Confirm Booking

      elsif travel_manager_view?
        # Request selection, Confirm Booking
        if travel_request.booking_pending? and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(travel_manager)
          actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:request_selection] = {method: 'patch', type: 9, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:confirm_booking] = {method: 'patch', type: 11, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      elsif manager_view?
        # Approve, Reject, Reject request
        if travel_request.processing? and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
          actions[:approve] = {method: 'patch', type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Confirm Selection
        if travel_request.selection_requested? and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
          actions[:confirm_selection] = {method: 'patch', type: 10, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Approve Selection
        if travel_request.selection_processing? and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
          actions[:approve_selection] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:reject_selection] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      elsif personal_view?
        # Submit
        if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
          actions[:submit] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Retract
        if travel_request.processing? && travel_request.user_id == user.id
          actions[:retract] = {method: 'patch', type: 3, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Confirm selection
        if travel_request.selection_requested? && travel_request.user_id == user.id
          actions[:confirm_selection] = {method: 'patch', type: 10, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
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

    def can_cancel_booking?
      can_add_booking?
    end

    def can_add_booking?
      travel_manager_view? and travel_request.controlling_user_id == user.id and user.travel_manager?
    end

    def can_add_options?
      can_add_booking?
    end

    def can_add_request?
      return true if can_add_booking?
      personal_view? and (travel_request.open? || self.travel_request.rejected? || self.travel_request.retracted?) and travel_request.user_id == user.id
    end

    def can_select_options?
      (manager_view? or personal_view?) and (travel_request.selection_requested?)
    end

    def editable
      if self.travel_request.open? || self.travel_request.rejected? || self.travel_request.retracted?
        return true if self.travel_request.user_id == self.user.id
      else
        return true if self.travel_request.controlling_user_id == user.id
        return true if travel_manager_view? and self.travel_request.controlling_user_id.blank?
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
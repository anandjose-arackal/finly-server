class TravelRequests::Show < TravelRequests::Base
  attr_accessor :travel_request, :booking_types

  def init
    self.travel_request = TravelRequest.find(params[:id]) #todo Scope to company
    self.booking_types = BookingType.all
  end

  def validate
    if travel_request.blank?
      add_message :error, 'Travel Request not found'
    end
  end

  def process
  end

  def success
    params[:travel_request] = self.travel_request
    params[:booking_types] = self.booking_types
    TravelRequests::Show::ShowPresenter.new(user, params, messages)
  end

  class TravelRequests::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :travel_request, :destinations, :booking_types,
                  :manager, :travel_manager

    def init
      self.travel_request = params[:travel_request]
      self.destinations = travel_request.destinations
      self.booking_types = params[:booking_types]
      self.manager = User::Team::Approver.(self.travel_request.user, travel_request: self.travel_request, type: :manager)
      self.travel_manager = User::Team::Approver.(self.travel_request.user, travel_request: self.travel_request, type: :travel_manager)
    end

    def actions
      actions = {}
      # todo associated_users
      if (travel_request.open? || travel_request.retracted?) && travel_request.user_id == user.id
        actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      elsif travel_request.processing?
        if travel_request.controlling_user_id == user.id && (manager_view? && user.manager?)
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

    def editable
      if self.travel_request.open? || self.travel_request.processing?
        if self.travel_request.controlling_user_id == self.user.id
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

  end

end
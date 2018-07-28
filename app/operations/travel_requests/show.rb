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

    def grouped_requests(destination)
      val = {}
      destination.booking_requests.each do |booking_request|
        if val[booking_request.booking_type_id].nil?
          val[booking_request.booking_type_id] = []
        end
        val[booking_request.booking_type_id] << booking_request
      end
      val
    end

  end

end
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
    attr_accessor :travel_request, :manager_user, :travel_managers, :reviewal_chains, :reviewal_chains_booking, :provider_name

    def init
      self.travel_request = params[:travel_request]

      self.reviewal_chains = []
      self.reviewal_chains_booking = []

      # todo - Select provider based status
      self.provider_name = "TravelRequestBookingProvider"


      params[:reviewal_document] = travel_request
      policies.each do |policy|
        params[:policy_id] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain
        }
        self.reviewal_chains.push(chain)
      end

      params[:provider_name] = "TravelRequestBookingProvider"
      policies.each do |policy|
        params[:policy_id] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain
        }
        self.reviewal_chains_booking.push(chain)
      end
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      if op.success?
        return op.chain
      else
        return nil
      end

    end

    def booking_types
      BookingType.all
    end

    def destinations
      travel_request.destinations
    end

    def policies
      if travel_request.user.enforce_policy_enabled?
        return travel_request.user.policies.non_default
      end
      travel_request.user.policies
    end

    def manager
      if self.manager_user.blank?
        self.manager_user = User::Team::Approver.(self.travel_request.user, travel_request: self.travel_request, type: :manager)
      end
      self.manager_user
    end

    # def travel_manager
    #   if self.travel_manager_user.blank?
    #     self.travel_manager_user = User::Team::Approver.(self.travel_request.user, travel_request: self.travel_request, type: :travel_manager)
    #   end
    #   self.travel_manager_user
    # end

    def travel_managers
      self.travel_request.document_role_users(:travel_managers)
    end

    def actions
      # actions = {editable: editable, destroyable: destroyable}
      # controlling_user = travel_request.controlling_user # || travel_request.controlling_for_user
      # controlling_user_role_id = travel_request.controlling_user_role_id # || travel_request.controlling_for_user_role_id
      # if admin_view?
      #   # if travel_request.processing? and not travel_request.controlling_user_id == travel_request.user_id
      #   #   actions[:take_control] = {method: "patch", type: 6, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   # end
      #   if self.travel_request.can_take_control? && not self.travel_request.get_reviewers.include?(user)
      #
      #     # todo Take Control
      #     actions[:take_control] = {}
      #   else
      #     actions[:approve] = {method: 'patch', type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #     actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #     actions[:confirm_booking] = {method: 'patch', type: 11, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      #   # todo Approve, Reject, Select Booking, Confirm Booking
      # end
      #
      # if travel_manager_view?
      #   # Request selection, Confirm Booking
      #   # if (travel_request.booking_pending? or travel_request.processing? or travel_request.selection_confirmed?) and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:travel_manager)
      #   if (travel_request.booking_pending? or travel_request.processing? or travel_request.selection_confirmed?) and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:travel_manager)
      #     actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #     actions[:request_selection] = {method: 'patch', type: 9, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #     actions[:confirm_booking] = {method: 'patch', type: 11, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      #   if travel_request.selection_requested? or travel_request.selection_processing?
      #     actions[:retract_request_selection] = {method: 'patch', type: 12, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      # end
      # if manager_view? or admin_view?
      #   # Approve, Reject, Reject request
      #   if travel_request.processing? and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
      #     actions[:approve] = {method: 'patch', type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #     actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      # end
      # # Confirm Selection
      # if (travel_request.selection_requested? or travel_request.selection_rejected?) and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
      #   actions[:confirm_selection] = {method: 'patch', type: 10, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # end
      # # Approve Selection
      # if travel_request.selection_processing? and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
      #   actions[:approve_selection] = {method: 'patch', type: 12, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   actions[:reject_selection] = {method: 'patch', type: 13, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # end
      # if personal_view?
      #   # Submit
      #   if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
      #     actions[:submit] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      #   # Retract
      #   if travel_request.processing? && travel_request.user_id == user.id and personal_view?
      #     actions[:retract] = {method: 'patch', type: 3, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      #   # Confirm selection
      #   if (travel_request.selection_requested? or travel_request.selection_rejected?) && travel_request.controlling_user_id == user.id
      #     actions[:confirm_selection] = {method: 'patch', type: 10, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      # end
      #
      # # case travel_request.controlling_user_role_id
      # # when nil
      # # when UserRole.id_for(:employee)
      # #   if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
      # #     actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # #   end
      # # when UserRole.id_for(:manager)
      # # when UserRole.id_for(:travel_manager)
      # # end
      # # todo associated_users
      # # if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
      # #   actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # # elsif travel_request.processing?
      # #   if travel_request.controlling_user_id == user.id && (user.manager?)
      # #     actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # #     actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # #   elsif user.company_admin? && admin_view?
      # #     actions[:take_control] = {method: "patch", type: 6, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # #   elsif user.employee? && self.travel_request.user_id == user.id
      # #     actions[:retract] = {method: "patch", type: 3, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # #   end
      # # elsif travel_request.approved?
      # #   if travel_request.controlling_user_id == user.id && user.travel_manager?
      # #     actions[:finish_booking] = {method: "patch", type: 7, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # #   end
      # # elsif travel_request.booked?
      # #   if travel_request.controlling_user_id == user.id && user.travel_manager?
      # #     actions[:retract_booking] = {method: "patch", type: 8, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # #   end
      # # end
      # actions





      actions = {editable: editable, destroyable: destroyable}
      controlling_user = travel_request.controlling_user # || travel_request.controlling_for_user
      controlling_user_role_id = travel_request.controlling_user_role_id # || travel_request.controlling_for_user_role_id
      if admin_view?
        # if travel_request.processing? and not travel_request.controlling_user_id == travel_request.user_id
        #   actions[:take_control] = {method: "patch", type: 6, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        # end
        if self.travel_request.can_take_control? && self.travel_request.get_reviewers.include?(user)
          actions[:approve] = {method: 'patch', type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:confirm_booking] = {method: 'patch', type: 11, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        else
          actions[:take_control] = {method: 'patch', type: 6, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      end

      if travel_manager_view?
        # Request selection, Confirm Booking
        if (travel_request.booking_pending? or travel_request.processing? or travel_request.selection_confirmed?) and self.travel_request.document_role_users(:travel_manager).include?(user)
          actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:request_selection] = {method: 'patch', type: 9, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:confirm_booking] = {method: 'patch', type: 11, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        if travel_request.selection_requested? or travel_request.selection_processing?
          actions[:retract_request_selection] = {method: 'patch', type: 12, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      end
      if manager_view?
        # Approve, Reject, Reject request
        if travel_request.processing? and self.travel_request.get_reviewers.include?(user)
          actions[:approve] = {method: 'patch', type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
          actions[:reject] = {method: 'patch', type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      end
      # Confirm Selection
      if (travel_request.selection_requested? or travel_request.selection_rejected?) and controlling_user&.id == user.id and controlling_user_role_id == UserRole.id_for(:manager)
        actions[:confirm_selection] = {method: 'patch', type: 10, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      end
      # Approve Selection
      if travel_request.selection_processing? and travel_request.get_reviewers(:current, provider_name)
        actions[:approve_selection] = {method: 'patch', type: 12, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        actions[:reject_selection] = {method: 'patch', type: 13, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      end
      if personal_view?
        # Submit
        if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
          actions[:submit] = {method: 'patch', type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Retract
        if travel_request.processing? && travel_request.user_id == user.id and personal_view?
          actions[:retract] = {method: 'patch', type: 3, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
        # Confirm selection
        if (travel_request.selection_requested? or travel_request.selection_rejected?) && travel_request.controlling_level_id.blank?
          actions[:confirm_selection] = {method: 'patch', type: 10, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
        end
      end

      # case travel_request.controlling_user_role_id
      # when nil
      # when UserRole.id_for(:employee)
      #   if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
      #     actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      # when UserRole.id_for(:manager)
      # when UserRole.id_for(:travel_manager)
      # end
      # todo associated_users
      # if (travel_request.open? || travel_request.retracted? || travel_request.rejected?) && travel_request.user_id == user.id
      #   actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      # elsif travel_request.processing?
      #   if travel_request.controlling_user_id == user.id && (user.manager?)
      #     actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #     actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   elsif user.company_admin? && admin_view?
      #     actions[:take_control] = {method: "patch", type: 6, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   elsif user.employee? && self.travel_request.user_id == user.id
      #     actions[:retract] = {method: "patch", type: 3, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      # elsif travel_request.approved?
      #   if travel_request.controlling_user_id == user.id && user.travel_manager?
      #     actions[:finish_booking] = {method: "patch", type: 7, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      # elsif travel_request.booked?
      #   if travel_request.controlling_user_id == user.id && user.travel_manager?
      #     actions[:retract_booking] = {method: "patch", type: 8, url: Rails.application.routes.url_helpers.travel_request_review_path(self.travel_request)}
      #   end
      # end
      actions
    end

    def can_view_money_request?(money_request)
      return false unless personal_view?
      !TravelRequestStatus.ids_for(:open, :processing, :retracted, :rejected).include?(self.travel_request.status_id)
    end

    def can_edit_money_request?(money_request)
      # return false unless personal_view?
      return false unless (money_request.user == user || money_request.get_reviewers.include?(user))
      TravelRequestStatus.ids_for(:open, :processing, :retracted, :rejected).include?(self.travel_request.status_id)
    end

    def can_cancel_booking?
      can_add_booking?
    end

    # def can_add_booking?
    #   travel_manager_view? and (travel_request.controlling_user_id == user.id || travel_request.controlling_user_id == nil) and user.travel_manager?
    # end

    def can_add_booking?
      travel_manager_view? && (travel_request.document_role_users(:travel_managers).include?(user)) && user.travel_manager?
    end

    # def can_add_options?
    #   can_add_booking? and not travel_request.controlling_user_id == nil
    # end

    def can_add_options?
      can_add_booking?
    end

    def can_add_request?
      # return true if can_add_booking?
      personal_view? and (travel_request.open? || self.travel_request.rejected? || self.travel_request.retracted?) and travel_request.user_id == user.id
    end

    def can_select_options?
      # (manager_view? or personal_view?) and (travel_request.selection_requested? or travel_request.selection_rejected?) and travel_request.controlling_user_id == user.id
      # NEW CODE
      (manager_view? or personal_view?) and (travel_request.selection_requested? or travel_request.selection_rejected?) and (travel_request.user_id == user.id || travel_request.associated_users(:interacted).include?(user))
    end

    def editable
      if self.travel_request.open? || self.travel_request.rejected? || self.travel_request.retracted?
        return true if self.travel_request.user_id == self.user.id and personal_view?
      else
        # return true if self.travel_request.controlling_user_id == user.id and travel_manager_view?
        # return true if travel_manager_view? and self.travel_request.controlling_user_id.blank?

        # New CODE
        return true if self.travel_request.document_role_users(:travel_managers).include?(user) and travel_manager_view?
      end
      false
    end

    def destroyable
      return false unless TravelRequestStatus.ids_for(:open, :retracted, :rejected).include?(self.travel_request.status_id)
      # return false unless self.travel_request.controlling_user_id == self.user.id
      # New CODE
      return false unless self.travel_request.user_id == self.user.id
      return false unless personal_view?
      true
    end

    def can_create_money_requests?
      return false if travel_request.reports.present?
      return false unless personal_view?
      return false unless TravelRequestStatus.ids_for(:open, :retracted, :rejected, :booking_confirmed).include?(self.travel_request.status_id)
      return false if travel_request.to_date and travel_request.to_date < Date.today
      true
    end

    def show_money_requests?
      true
    end

    def can_create_reports?
      return false unless personal_view?
      not TravelRequestStatus.ids_for(:open, :processing, :retracted, :rejected, :cancelled).include?(travel_request.status_id)
    end

    def show_reports?
      travel_request.booking_confirmed?
    end

    def reports
      travel_request.reports
    end

    def money_requests
      travel_request.money_requests
    end

    def grouped_bookings(destination)
      val = {}
      destination.bookings.without_parent.each do |booking|
        if val[booking.booking_type&.name].nil?
          val[booking.booking_type&.name] = []
        end
        booking_json = booking.as_json
        booking_json[:alert] = alert_for(booking)
        val[booking.booking_type&.name] << booking_json
      end
      val
    end

    def alert_for(booking)
      highlighted = false
      message = ''
      if travel_request.controlling_user_id == user.id
        if travel_manager_view?
          if travel_request.processing? or travel_request.approved? or travel_request.booking_pending?
            if booking.bookings.options.blank? and booking.bookings.confirmed.blank?
              highlighted = true
              message = 'No bookings or options have been added'
            end
          elsif travel_request.selection_confirmed?
            if booking.bookings.selected_for_booking.present?
              highlighted = true
              message = 'Option selected. Awaiting booking'
            end
          end
        else
          if travel_request.selection_requested?
            options_count = booking.bookings.options.size
            if options_count > 0 and booking.bookings.selected_for_booking.size == 0 and booking.bookings.confirmed.size == 0
              highlighted = true
              message = "#{options_count} options available for selection"
            end
          elsif travel_request.selection_processing?
            selected_for_booking_count = booking.bookings.selected_for_booking.size
            if selected_for_booking_count > 0
              highlighted = true
              message = 'Selected for booking'
            end
          end
        end
      end
      {highlighted: highlighted, message: message}
    end

    def custom_fields_for(policy, type)
      return nil unless policy.present?
      policy.field_configurations.exclude_deleted.root_fields.order_created_at_desc.with_parent_type(FieldParentType.id_for(type))
    end

  end

end
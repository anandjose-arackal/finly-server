class Admin::Cards::AssignRequests::Index < Admin::Cards::AssignRequests::Base
  attr_accessor :card_assign_requests, :workflow, :reviewer_level

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.workflow = AdminReviewWorkflow.workflow_for :assign_card
    self.reviewer_level = workflow.levels.with_admin_user(user.id)&.first
    if self.workflow.present? and self.reviewer_level.present?
      self.card_assign_requests = CardAssignRequest.with_admin_review_workflow(self.workflow.id).with_review_position(reviewer_level.position).include_tracks
    else
      add_message :error, 'User is not a reviewer'
      return
    end

    # If the user is kalpesh, do not show once downloaded
    if is_view?(:itzcash_operations) and self.card_assign_requests.present?
      assign_request_ids = self.card_assign_requests.pluck(:id)
      request_ids_to_hide = CardAssignRequestTrack.with_card_assign_request(assign_request_ids).with_action(CardAssignRequestTrackAction.id_for(:download)).with_action_admin_resource(user.id).created_after(24.hours.ago).pluck(:card_assign_request_id)
      self.card_assign_requests = self.card_assign_requests.without_id(request_ids_to_hide)
    end
  end

  def validate

  end

  def success
    params[:card_assign_requests] = self.card_assign_requests
    Admin::Cards::AssignRequests::Index::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :card_assign_requests

    has_scope :filter_company_id

    def init
      self.card_assign_requests = params[:card_assign_requests]
      self.card_assign_requests = apply_scopes(self.card_assign_requests).paginate(page: params[:page], per_page: 30) if self.card_assign_requests.present?
    end

    def company_for(card_assign_request)
      card_assign_request&.card_owner&.company
    end

    def kyc_for(card_assign_request)
      card_assign_request&.card_owner&.individual_kyc
    end

    def actions_for(card_assign_request)
      actions = {}
      return actions if card_assign_request.blank? or not card_assign_request.processing?
      if user.has_role?(AdminUserRole.id_for(:verifier)) or user.has_role?(AdminUserRole.id_for(:itzcash_verifier))or
          user.has_role?(AdminUserRole.id_for(:itzcash_operations))
        is_reviewer_presenter = Admin::Cards::AssignRequests::Accessable.(user, admin_user: user, card_assign_request: card_assign_request)
        if is_reviewer_presenter.success? and is_reviewer_presenter.is_reviewer
          actions[:approve] = true
          actions[:reject] = true
        end
      end
      actions
    end
  end

end
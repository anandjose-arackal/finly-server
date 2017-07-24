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
    self.reviewer_level = workflow.levels.with_admin_reviewer(user.id)&.first
    if self.workflow.present? and self.reviewer_level.present?
      self.card_assign_requests = CardAssignRequest.with_admin_review_workflow(self.workflow.id).with_review_position(reviewer_level.position)
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
      self.card_assign_requests = apply_scopes(params[:card_assign_requests])
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
      next_reviewer_presenter = Admin::Cards::AssignRequests::NextAdminReviewPosition.(user, admin_user: user, card_assign_request: card_assign_request)
      if next_reviewer_presenter.success? and next_reviewer_presenter.is_final? and user.has_role?(AdminUserRole.id_for(:itzcash_operations))
        actions.delete(:approve)
        actions[:mark_as_assigned] = true
        actions[:mark_as_upgraded] = true
      end
      actions
    end
  end

end
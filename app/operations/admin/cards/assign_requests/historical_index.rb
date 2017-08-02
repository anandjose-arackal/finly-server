class Admin::Cards::AssignRequests::HistoricalIndex < Admin::Cards::AssignRequests::Base
  attr_accessor :card_assign_requests, :workflow, :reviewer_level

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    tracks = CardAssignRequestTrack.with_action_admin_resource(user.id)
    self.card_assign_requests = CardAssignRequest.with_id(tracks.pluck(:card_assign_request_id))
  end

  def validate

  end

  def success
    params[:card_assign_requests] = self.card_assign_requests
    Admin::Cards::AssignRequests::HistoricalIndex::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignRequests::HistoricalIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
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
      {}
    end
  end

end
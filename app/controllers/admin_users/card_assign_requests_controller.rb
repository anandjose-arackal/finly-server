class AdminUsers::CardAssignRequestsController < ApplicationController

  before_action :set_tokens_in_header_admin, only: [:export, :download_kycs]
  before_action -> { doorkeeper_authorize! :admin }

  def index
    @result = Admin::Cards::AssignRequests::Index.(current_user, params)
    respond
  end

  def history_index
    @result = Admin::Cards::AssignRequests::HistoricalIndex.(current_user, params)
    respond
  end

  def edit
    @states = State.all
  end

  def update
    formatted_request = RequestFormatter::KycParser::Parse.(current_user, params).formatted_request
    @result = Admin::Cards::AssignRequests::Update.(current_user, formatted_request)
    respond response: @result.success? ? :success : :failure
  end

  def approve
    @result = Admin::Cards::AssignRequests::Approve.(current_user, params)
    respond
  end

  def reject
    @result = Admin::Cards::AssignRequests::Reject.(current_user, params)
    respond
  end

  def mark_as_assigned
    @result = Admin::Cards::AssignRequests::MarkAsAssigned.(current_user, params)
    respond
  end

  def mark_as_assigned_upgraded
    @result = Admin::Cards::AssignRequests::MarkAsAssigned.(current_user, params)
    respond
  end

  def export
    @result = Admin::Cards::AssignRequests::Export::AsXls.(current_user, params)
    respond
  end

  def download_kycs
    @result = Admin::Cards::AssignRequests::Export::KycsAsZip.(current_user, params)
    respond
  end

end

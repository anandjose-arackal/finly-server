class AdminUsers::Kyc::UsersController < BaseControllers::AdminBase

  set_tokens_in_header :export, :download_kycs

  def index
    @result = Admin::KycProcesses::Users::Index.(current_user, params)
    respond
  end

  def history_index
    @result = Admin::KycProcesses::Users::HistoricalIndex.(current_user, params)
    respond
  end

  def update
    formatted_request = RequestFormatter::KycParser::Parse.(current_user, params).formatted_request
    @result = Admin::KycProcesses::Users::Update.(current_user, formatted_request)
    respond response: @result.success? ? :success : :failure
  end

  def approve
    @result = Admin::KycProcesses::Users::Approve.(current_user, params)
    respond
  end

  def reject
    @result = Admin::KycProcesses::Users::Reject.(current_user, params)
    respond
  end

  def mark_as_upgraded
    @result = Admin::KycProcesses::Users::MarkAsUpgraded.(current_user, params)
    respond
  end

  def export
    @result = Admin::KycProcesses::Users::Export::AsXls.(current_user, params)
    respond
  end

  def download_kycs
    @result = Admin::KycProcesses::Users::Export::KycsAsZip.(current_user, params)
    respond
  end

end

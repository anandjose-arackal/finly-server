class Report::AutoSubmit < Report::Base
  attr_accessor :processing_expenses, :auto_submit_config, :selected_user

  def pre_validate
    super
    return if has_errors?
    if params[:user].blank? and params[:user_id].blank? and params[:id].blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.selected_user = params[:user]
    if selected_user.blank?
      id = (params[:user_id] and params[:id])
      self.selected_user = User::Team::Index.(user, params).with_id(id).first rescue nil if id.present?
    end
    return if self.selected_user.present?
    self.auto_submit_config = selected_user.auto_submit_config
    if selected_user.auto_submit_config.enabled
      self.processing_expenses = Expense::Index.(selected_user)
    end
  end

  def validate
    if selected_user.blank?
      add_message :error, 'User not found'
      return
    end
    unless auto_submit_config.present? and auto_submit_config.enabled
      add_message :error, 'Auto submit has not been enabled for the user'
    end
  end

  def process
    return if self.processing_expenses.blank?

    presenter = Report::Create.(nil, for_user: selected_user, auto_submit: true, expenses: self.processing_expenses)
    unless presenter.success?
      add_message :error, presenter.messages[:error]
      return
    end
    report = presenter.report
    Report::Submit.(nil, auto_submit: true, report: report)
  end

end
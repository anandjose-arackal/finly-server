class Event::EReport::Base < Event::SetNotifier
  attr_accessor :report, :rejected_expenses

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:report].blank?
      add_message :error, 'Report not found'
      return
    end
    unless params[:report].is_a?(::Report)
      add_message :error, 'Error loading report'
    end
  end

  def init
    self.report = params[:report]
  end

  def validate
    unless self.report.present?
      add_message :error, 'Report not found'
    end
  end

  def send_mailer(user)
  	return if user.blank?
    set_presenter_params
    return unless params[:subject].present? and params[:body].present?
    ReportMailer.delay.send_mail(Event::EReport::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    if report.controlling_user_id.present? and
      user.id == report.controlling_user_id and not user.id == report.user.id
      'Review Report'
    else
      'View Report'
    end
  end

  def set_presenter_params
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
  end

  class Event::EReport::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :report, :user, :body_val, :subject_val, :button_val, :categories, :expenses, :rejected_expenses, :event_id,
                  :action_name, :comment_body

    def initialize(user, params)
      self.report = params[:report]
      self.categories = user.company.categories.active
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.expenses = report.expenses
      self.rejected_expenses = params[:rejected_expenses]
      self.event_id = params[:event_id]
      self.action_name = params[:action_name]
      self.comment_body = params[:comment_body]
    end

    def expenses_category_sorted
      categorized_expenses = []
      self.categories.each do |category|
        item_expenses = self.expenses.with_category(category.id)
        if item_expenses.present?
          item_name = category.name
          item_sum = precision_value item_expenses.with_amount.sum(:value)
          categorized_expenses << {section_name: item_name, expenses: item_expenses, section_total: item_sum}
        end
      end
      categorized_expenses
    end

    def validate
      self.user.present? and self.report.present?
    end

    def to
      self.user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end

    def button_name
      self.button_val
    end

  end

end

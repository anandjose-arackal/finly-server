class Budgets::BulkUpdate < Budgets::Base

  attr_accessor :issues, :valid

  def pre_validate
    if params[:budget_items].blank?
      add_message :error, "Nothing sent."
      return
    end
  end

  def init
    self.valid = true
    self.issues = []
  end

  def validate
  end

  def process
    params[:budget_items].each do |item|
      item[:budget_id] = params.dig(:item, :budget_id)
      if item[:budget_id].blank?
        add_message :error, "Budget details missing. Please contact customer support."
        break
      end
      op = Budgets::Update.(user, item)
      unless op.success?
        self.valid = false
        item[:issues] = op.messages[:error]
        issues << item
      end
    end

    unless valid
      add_message :error, "Some of the budgets could not be updated"
      return
    end
  end

  def post_process
    add_message :success, "All budgets were updated."
  end

  def failure
    params[:issues] = self.issues
    Budgets::BulkUpdate::FailurePresenter.new(user, params, messages)
  end

  class Budgets::BulkUpdate::FailurePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :issues

    self.issues = params[:issues]
  end


end

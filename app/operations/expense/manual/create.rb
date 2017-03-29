# Class to create an expense
# format of parameters,

class Expense::Manual::Create < Expense::Manual::Base
  attr_accessor :expense_params, :receipt

  # only employees can create expenses

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super
    if params.blank?
      add_message :error, 'Parameters not present'
    end
    if params[:expense].blank?
      add_message :error, 'You have not provided any details to create an expense'
      return
    end
    amount_value = params[:expense][:amount_attributes][:value].to_d rescue nil
    if amount_value.present? and amount_value <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
    end
  end

  def init
    self.expense_params = manual_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.manual_expense_id
    if params[:receipt_id].present?
      self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    end
    if expense_params[:receipts_attributes] == [nil]
      expense_params.delete(:receipts_attributes)
    end
  end

  def validate
    # can't think of anything for now
    if expense_params[:receipt_id].present? and receipt.blank?
      add_message :error, 'Receipt not found'
      return false
    end

    # checking if the report is editable for personal view
    if personal_view? and expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      unless report.editable?
        add_message :error, 'Expense cannot be added to the report in this state'
      end
    end
  end


  def process
    self.expense = user.expenses.build(expense_params)
    if self.expense.valid?
      custom_fields = (params[:custom_fields] or {})
      custom_fields[:reset_fields] = true
      custom_fields[:save] = false
      CustomField::SetFields.(self.expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return
      end
      valid = CustomField::Validate.(self.expense.manual_expense)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return
      end
    end
    if self.expense.save
      # Attach an existing receipt to the expense
      if self.receipt.present?
        self.receipt.parent = expense
        self.receipt.save
      end
    else
      add_message :error, self.expense.errors.full_messages
    end
  end

  def post_process
    # add comment in report if expense is added within report
    if self.expense.report_id.present? and self.expense.report.retracted?
      comment = self.expense.report.comments.build report: self.expense.report, user: user,
                                                   report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
      unless comment.save
        add_message :error, comment.errors.full_messages
      end
    end
    add_message :success, 'Expense created'
  end

  # def success
  #   Expense::Manual::Create::CreatePresenter.new(expense)
  # end

end

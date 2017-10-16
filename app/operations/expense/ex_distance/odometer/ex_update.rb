# operation to create a distance expense
# parameters :
# id: id of the expense that is to be updated
# expense: { distance_expense_attributes: { distance_attributes: { value:  of the distance in km
#                                                                }
#                                         }
#            note: "Sample note"
#            category_id: 2
#            date: "25-01-17"
#            expense_type_id: 3
#            expense_status_id: 4
#          }
# type: '3' for distance expense
# }


class Expense::ExDistance::Odometer::ExUpdate < Expense::ExDistance::Update

  attr_accessor :receipt_start, :receipt_end, :old_receipt_start, :old_receipt_end

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << 'Parameters or user not found'
      return false
    end
    if params[:expense_id].nil? and params[:id].blank?
      messages[:error] << 'Expense ID missing!'
      return false
    end
  end

  def init
    id = (params[:expense_id] or params[:id])
    self.expense = Expense::Index.(user, params)&.expenses&.find_by(id: id)

    if self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_start).present? and
        self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_end).present?
      start_val = self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_start)
      end_val = self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_end)
      self.params[:expense][:distance_expense_attributes][:distance_attributes] = {
          value: (end_val - start_val),
          physical_unit_id: PhysicalUnit.kilometre_id
      }
    end

    # saving previous expense attributes before updation
    define_editable_attributes if expense

    # setting up the expense params for updation
    self.updated_expense_params = distance_expense_params

    if expense
      if self.updated_expense_params[:distance_expense_attributes].present? and expense.distance_expense.present?
        self.updated_expense_params[:distance_expense_attributes][:id] = expense.distance_expense.id
      end
      if self.updated_expense_params&.dig(:distance_expense_attributes, :distance_attributes).present? and expense.distance_expense.distance_id.present?
        self.updated_expense_params[:distance_expense_attributes][:distance_attributes][:id] = expense.distance_expense.distance.id
      end

      init_receipts
    end
  end

  def validate
    super
    return if has_errors?
    receipt_start_id = updated_expense_params(:distance_expense_attributes, :odometer_reading_receipt_start_id)
    receipt_end_id = updated_expense_params(:distance_expense_attributes, :odometer_reading_receipt_end_id)
    if receipt_start_id.present? and self.receipt_start.blank?
      add_message :error, 'Start Reading Receipt not found'
      return
    end
    if receipt_end_id.present? and self.receipt_end.blank?
      add_message :error, 'End Reading Receipt not found'
      return
    end
  end

  def process
    super
    return if has_errors?
    if self.receipt_start.present? and self.receipt_start != self.old_receipt_start
      self.old_receipt_start.update(parent: nil)
      self.receipt_start.update(parent: self.expense)
    end
    if self.receipt_end.present? and self.receipt_end != self.old_receipt_end
      self.old_receipt_end.update(parent: nil)
      self.receipt_end.update(parent: self.expense)
    end
  end

  def post_process
    # add comment in report if expense is added within report
    Report::Expenses::UpdateComment.(self.user, updated_expense: self.expense, updated_attributes: editable_attrs)

    # if the expense has an associated amount, update the amount
    if expense.amount.present? && expense.report.present?
      amount = expense.amount
      amount.update(value: expense.calculate_amount_value(expense.report.policy))
    end

    # checking if the expense has any receipts, and marking them all as no need to be transcribed
    if expense.receipts.present?
      expense.receipts.update_all(to_be_transcribed: false)
    end

    # updating the respective amounts table with the conversion rates
    if expense.date == DateUtils.local_date
      if expense.report.present? && expense.amount.currency_id != expense.report.base_currency_id
        expense.destroy_other_currencies
      end
    else
      expense.update_other_currencies
    end

    add_message :success, 'Expense updated'
  end

  protected

  def distance_expense_params
    params.require(:expense).permit(:note, :category_id, :date,
                                    :expense_type_id, :expense_status_id,
                                    :report_id, :reimbursable,
                                    distance_expense_attributes: [:type_id, :odometer_reading_start, :odometer_reading_end,
                                                                  :odometer_reading_receipt_start_id, :odometer_reading_receipt_end_id,
                                                                  distance_attributes: [:value, :physical_unit_id]])
  end

  def init_receipts
    self.receipt = nil
    self.old_receipt_start = self.expense.distance_expense.odometer_reading_receipt_start
    self.old_receipt_end = self.expense.distance_expense.odometer_reading_receipt_end
    receipt_start_id = updated_expense_params(:distance_expense_attributes, :odometer_reading_receipt_start_id)
    receipt_end_id = updated_expense_params(:distance_expense_attributes, :odometer_reading_receipt_end_id)
    if receipt_start_id.present?
      self.receipt_start = user.receipts.without_parent.find_by_id(receipt_start_id)
      if self.receipt_start.blank?
        if receipt_start_id == expense.distance_expense&.odometer_reading_receipt_start_id
          self.receipt_start = expense.distance_expense&.odometer_reading_receipt_start
        elsif receipt_start_id == expense.distance_expense&.odometer_reading_receipt_end_id
          self.receipt_start = expense.distance_expense&.odometer_reading_receipt_end
        end
      end
    end
    if receipt_end_id.present?
      self.receipt_end = user.receipts.without_parent.find_by_id(receipt_end_id)
      if self.receipt_end.blank?
        if receipt_end_id == expense.distance_expense&.odometer_reading_receipt_start_id
          self.receipt_end = expense.distance_expense&.odometer_reading_receipt_start
        elsif receipt_end_id == expense.distance_expense&.odometer_reading_receipt_end_id
          self.receipt_end = expense.distance_expense&.odometer_reading_receipt_end
        end
      end
    end
  end

end
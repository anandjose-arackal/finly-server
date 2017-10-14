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

  attr_accessor :receipt_start, :receipt_end

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
      receipt_start_id = updated_expense_params(:distance_expense_attributes, :odometer_reading_receipt_start_id)
      receipt_end_id = updated_expense_params(:distance_expense_attributes, :odometer_reading_receipt_end_id)
      if receipt_start_id.present?

      end
      if receipt_end_id.present?

      end
    end
  end

  def authorize
    unless expense
      raise_unauthorized_exception
    end
    # i.e. if an employee is editing an expense
    if personal_view? and expense.user_id != user.id
      raise_unauthorized_exception
    end
  end

  def validate
    if expense.report_id and personal_view?
      unless expense.report.editable?
        messages[:error] << 'Expense cannot be edited at this stage'
        return
      end
    end
    if receipt
      unless receipt.user_id == user.id
        add_message :error, "You do not own this receipt"
      end
    end
  end

  def process
    # Set custom fields
    custom_fields = {custom_fields: params[:custom_fields]}
    custom_fields[:save] = false
    set_fields = CustomField::SetFields.(self.expense.distance_expense, FieldParentType.id_for(:distance_expense), custom_fields)
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    # valid = CustomField::Validate.(self.expense.distance_expense)
    # unless valid.success?
    #   add_message :error, valid.messages[:error]
    #   return
    # end

    if expense.update(updated_expense_params)
      expense.distance_expense.locations.with_id(locations_marked_for_destruction).destroy_all if self.locations_marked_for_destruction.present?
      if self.destroy_receipts
        expense.receipts.each do |receipt|
          if receipt
            receipt.parent = nil
            receipt.save
          end
        end
      end
      if receipt
        receipt.parent = expense
        if receipt.save
          if old_receipt.present?
            old_receipt.parent = nil
            old_receipt.save
          end
        end
      end
    else
      add_message :error, self.expense.errors.full_messages
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

end
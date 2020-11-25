# operation to create a distance expense
# parameters :
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


class Expense::ExDistance::Odometer::ExCreate < Expense::ExDistance::Create
  attr_accessor :receipt_start, :receipt_end, :start_reading, :end_reading

  def personalizer
    {
        validate: {
            before: Personalizer::Process.new([:expense, :ex_distance, :odometer, :ex_create], :validate, self)
        }
    }
  end

  def rollback_process_if_error?
    true
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters passed'
    end
    if params[:expense].blank?
      add_message :error, 'You have not provided any details to create an expense'
      return
    end
  end

  def init
    if self.params[:expense][:distance_expense_attributes].present?
      self.params[:expense][:distance_expense_attributes][:type_id] = DistanceExpenseType.id_for(:odometer)
    end
    if self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_start).present? and
        self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_end).present?
      start_val = self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_start).to_f
      end_val = self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_end).to_f
      self.params[:expense][:distance_expense_attributes][:distance_attributes] = {
          value: (end_val - start_val),
          physical_unit_id: PhysicalUnit.kilometre_id
      }
    end

    super

    return if has_errors?
    receipt_start_id = params&.dig(:expense, :distance_expense_attributes, :odometer_reading_receipt_start_id)
    receipt_end_id = params&.dig(:expense, :distance_expense_attributes, :odometer_reading_receipt_end_id)
    if receipt_start_id.present?
      self.receipt_start = user.receipts.without_parent.find_by_id(receipt_start_id)
    end
    if receipt_end_id.present?
      self.receipt_end = user.receipts.without_parent.find_by_id(receipt_end_id)
    end
  end

  def validate
    start_reading = params&.dig(:expense, :distance_expense_attributes, :odometer_reading_start)
    end_reading = params&.dig(:expense, :distance_expense_attributes, :odometer_reading_end)


    if start_reading.blank? || end_reading.blank?
      add_message :error, 'Start Reading can\'t be blank' if start_reading.blank?
      add_message :error, 'End Reading can\'t be blank' if end_reading.blank?
      return
    end
    if start_reading >= end_reading
      add_message :error, 'Start Reading can\'t be greater than End Reading'
      return
    end

    super
    return if has_errors?

    receipt_start_id = params&.dig(:expense, :distance_expense_attributes, :odometer_reading_receipt_start_id)
    receipt_end_id = params&.dig(:expense, :distance_expense_attributes, :odometer_reading_receipt_end_id)
    return add_message :error, 'Start Reading receipt not found' if receipt_start_id.present? and self.receipt_start.blank?
    return add_message :error, 'End Reading receipt not found' if receipt_end_id.present? and self.receipt_end.blank?
  end

  def process
    super
    return if has_errors?
    if self.receipt_start.present?
      self.receipt_start.update(parent: self.expense)
    end
    if self.receipt_end.present?
      self.receipt_end.update(parent: self.expense)
    end
  end

  def post_process
    super

    # Budget check
    budget_validation_op = budget_limit_validation(expense)
    if budget_validation_op.present? && budget_validation_op.failure? && budget_validation_op.messages[:errors].present?
      add_message :error, budget_validation_op.messages[:errors]
      return
    end
  end

  def distance_expense_params
    params.require(:expense).permit(:note, :category_id, :date,
                                    :expense_type_id,
                                    :report_id, :reimbursable, :spent_from_id, :created_by_id,
                                    distance_expense_attributes: [:type_id, :odometer_reading_start, :odometer_reading_end,
                                                                  :odometer_reading_receipt_start_id, :odometer_reading_receipt_end_id,
                                                                  :vehicle_rate_id,
                                                                  distance_attributes: [:value, :physical_unit_id]])
  end

end
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

  attr_accessor :receipt_start, :receipt_end, :old_receipt_start, :old_receipt_end,
                :remove_receipt_start, :remove_receipt_end, :remove_distance

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

    if self.params&.dig(:expense, :distance_expense_attributes)&.has_key?(:odometer_reading_start) or self.params&.dig(:expense, :distance_expense_attributes)&.has_key?(:odometer_reading_end)
      start_reading = self.params&.dig(:expense, :distance_expense_attributes)&.has_key?(:odometer_reading_start) ? self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_start) : self.expense.distance_expense.odometer_reading_start
      end_reading = self.params&.dig(:expense, :distance_expense_attributes)&.has_key?(:odometer_reading_end) ? self.params&.dig(:expense, :distance_expense_attributes, :odometer_reading_end) : self.expense.distance_expense.odometer_reading_end
      if start_reading.present? and end_reading.present?
        self.params[:expense][:distance_expense_attributes][:distance_attributes] = {
            value: ((Float (end_reading)) - (Float (start_reading))),
            physical_unit_id: PhysicalUnit.kilometre_id
        }
      else
        self.remove_distance = true
      end
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
        self.updated_expense_params[:distance_expense_attributes][:distance_attributes][:id] = expense&.distance_expense&.distance&.id
      end

      init_receipts
    end

    pocket_id = self.updated_expense_params[:spent_from_id]
    if pocket_id.blank?
      exp_params = params[:expense] || {}
      reimbursable = exp_params[:reimbursable]
      from_cash_on_hand = exp_params[:from_cash_on_hand]
      if reimbursable
        pocket_id = user.user_pockets.reimbursement_pocket_only&.first&.id
      elsif from_cash_on_hand
        pocket_id = user.user_pockets.cash_pockets_only&.first&.id
      elsif exp_params.key?(:reimbursable) || exp_params.key?(:from_cash_on_hand) # Legacy support for android app -> As android only sends the key which has been updated
        pocket_id = user.user_pockets.paid_by_company_pocket_only&.first&.id
      end
    end
    self.cash_pocket = user.user_pockets.non_bank_card_transfer_pockets.find_by(id: pocket_id) || expense&.spent_from

    if self.cash_pocket.blank?
      self.cash_pocket = user.user_pockets.cash_pockets_only.first
    end
    self.updated_expense_params[:spent_from_id] = self.cash_pocket&.id
  end

  def validate
    super
    return if has_errors?
    receipt_start_id = updated_expense_params&.dig(:distance_expense_attributes, :odometer_reading_receipt_start_id)
    receipt_end_id = updated_expense_params&.dig(:distance_expense_attributes, :odometer_reading_receipt_end_id)
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
    if remove_receipt_start
      self.old_receipt_start&.update(parent: nil)
    end
    if self.receipt_start.present? and self.receipt_start != self.old_receipt_start
      self.receipt_start.update(parent: self.expense)
    end
    if remove_receipt_end
      self.old_receipt_end&.update(parent: nil)
    end
    if self.receipt_end.present? and self.receipt_end != self.old_receipt_end
      self.receipt_end.update(parent: self.expense)
    end
    if self.remove_distance
      self.expense&.distance_expense&.distance&.destroy and self.expense&.distance_expense&.update(distance_id: nil)
    end
  end

  def post_process
    # add comment in report if expense is added within report
    Reports::Expenses::UpdateComment.(self.user, updated_expense: self.expense, updated_attributes: editable_attrs)

    # if the expense has an associated amount, update the amount
    if expense.report.present?
      if expense.amount.present?
        amount = expense.amount
        amount.update(value: expense.calculate_amount_value(expense.report.policy), currency_id: expense.report.policy.base_currency_id)
      else
        expense.amount = Amount.create(value: expense.calculate_amount_value(expense.report.policy), currency_id: expense.report.policy.base_currency_id)
        expense.save
      end
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

    # check if this expense's amount allows for it to be marked against COH
    # and if it is or is not, update the flag for this expense accordingly
    if expense.amount.present? && expense.from_cash_on_hand
      pocket = expense.spent_from
      if pocket.cash_pocket?
        pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
        if pocket_adapter.balance(display_balance: true) >= expense.amount_value
          expense.update(cash_on_hand_blocked: true)
        end
        if pocket_adapter.balance(display_balance: true) < 0
          expense.update(cash_on_hand_blocked: false)
        end
      elsif pocket.credit_card_pocket?
        expense.update(cash_on_hand_blocked: true)
      end
    end

    add_message :success, 'Expense updated'
  end

  protected

  def distance_expense_params
    return {} if params[:expense].blank?
    params.require(:expense).permit(:note, :category_id, :date,
                                    :expense_type_id, :expense_status_id,
                                    :report_id, :spent_from_id,
                                    distance_expense_attributes: [:type_id, :odometer_reading_start, :odometer_reading_end,
                                                                  :odometer_reading_receipt_start_id, :odometer_reading_receipt_end_id,
                                                                  distance_attributes: [:value, :physical_unit_id]])
  end

  def init_receipts
    self.receipt = nil
    self.old_receipt_start = self.expense.distance_expense.odometer_reading_receipt_start
    self.old_receipt_end = self.expense.distance_expense.odometer_reading_receipt_end
    receipt_start_id = updated_expense_params&.dig(:distance_expense_attributes, :odometer_reading_receipt_start_id)
    receipt_end_id = updated_expense_params&.dig(:distance_expense_attributes, :odometer_reading_receipt_end_id)
    if receipt_start_id.present?
      self.receipt_start = user.receipts.without_parent.find_by_id(receipt_start_id)
      if self.receipt_start.blank?
        if receipt_start_id&.to_i == expense.distance_expense&.odometer_reading_receipt_start_id
          self.receipt_start = expense.distance_expense&.odometer_reading_receipt_start
        elsif receipt_start_id&.to_i == expense.distance_expense&.odometer_reading_receipt_end_id
          self.receipt_start = expense.distance_expense&.odometer_reading_receipt_end
        end
      end
    end
    if receipt_end_id.present?
      self.receipt_end = user.receipts.without_parent.find_by_id(receipt_end_id)
      if self.receipt_end.blank?
        if receipt_end_id&.to_i == expense.distance_expense&.odometer_reading_receipt_start_id
          self.receipt_end = expense.distance_expense&.odometer_reading_receipt_start
        elsif receipt_end_id&.to_i == expense.distance_expense&.odometer_reading_receipt_end_id
          self.receipt_end = expense.distance_expense&.odometer_reading_receipt_end
        end
      end
    end
    if receipt_start_id == 'nil' or
        (updated_expense_params&.dig(:distance_expense_attributes)&.has_key?(:odometer_reading_receipt_start_id) and
            receipt_start_id.blank?) or (receipt_start_id.present? and self.receipt_start != self.old_receipt_start)
      self.remove_receipt_start = true
    end
    if receipt_end_id == 'nil' or
        (updated_expense_params&.dig(:distance_expense_attributes)&.has_key?(:odometer_reading_receipt_end_id) and
            receipt_end_id.blank?) or (receipt_end_id.present? and self.receipt_end != self.old_receipt_end)
      self.remove_receipt_end = true
    end
  end

end
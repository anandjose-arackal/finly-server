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


class Expense::ExDistance::Update < Expense::ExDistance::Base

  attr_accessor :updated_expense_params, :locations_marked_for_destruction
  attr_accessor :editable_attrs, :receipt, :old_receipt, :destroy_receipts

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << 'Parameters or user not found'
      return false
    end
    if params[:expense_id].nil? and params[:id].blank?
      messages[:error] << 'Expense ID missing!'
      return false
    end
    distance_value = params[:expense][:distance_expense_attributes][:distance_attributes][:value].to_d rescue nil
    if distance_value.present? and distance_value <= 0
      messages[:error] << 'Distance cannot be less than or equal to 0'
    end
  end

  def init
    super
    # saving previous expense attributes before updation
    define_editable_attributes if expense
    # setting up the expense params for updation
    self.updated_expense_params = distance_expense_params

    # todo set ids for locations using order
    self.locations_marked_for_destruction = expense&.distance_expense&.locations.pluck(:id)
    if expense&.distance_expense&.locations.count > 0
      pos = 1
      self.updated_expense_params&.dig(:distance_expense_attributes)&.dig(:locations_attributes)&.each do |location|
        id = expense&.distance_expense&.locations.with_order(pos)&.first&.id
        if id.present?
          self.locations_marked_for_destruction.delete(id)
          location[:id] = id
        end
        location[:order] = pos
        pos += 1
      end
    else
      pos = 1
      self.updated_expense_params&.dig(:distance_expense_attributes)&.dig(:locations_attributes)&.each do |location|
        location
        location[:order] = pos
        pos += 1
      end
    end

    if updated_expense_params[:receipts_attributes] == [nil] or updated_expense_params[:receipts_attributes] == [""]
      # if the receipts attributes is passed as [""], the receipt attached to this expense gets disassociated
      # todo - check if the api fails because of this
      # if updated_expense_params[:receipts_attributes] == [""]
        self.destroy_receipts = true
      # end
      updated_expense_params.delete(:receipts_attributes)
    end
    if expense
      if self.updated_expense_params[:distance_expense_attributes].present? and expense.distance_expense.present?
        self.updated_expense_params[:distance_expense_attributes][:id] = expense.distance_expense.id
      end
      if self.updated_expense_params&.dig(:distance_expense_attributes, :distance_attributes, :value).present? and expense.distance_expense.distance_id.present?
        self.updated_expense_params[:distance_expense_attributes][:distance_attributes][:id] = expense.distance_expense.distance.id
      end
      if expense.receipts.present? and updated_expense_params[:receipts_attributes].present?
        self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
      end
      if params[:receipt_id].present?
        # If a new receipt is attached from existing receipts, remove the old receipt
        self.old_receipt = expense.receipts.first if expense.receipts.present?
        self.receipt = user.receipts.find_by(id: params[:receipt_id])
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
    valid = CustomField::Validate.(self.expense.distance_expense)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end

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

  private

  def define_editable_attributes
    self.editable_attrs = {note: expense.note,
                           date: expense.date,
                           distance_value: expense.distance_value,
                           category_name: expense.category_name,
                           receipt: expense.receipts.count
    }
  end

end
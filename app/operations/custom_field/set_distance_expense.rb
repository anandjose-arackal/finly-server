set_manual_expense.rb# Expected params -> {report: {custom_fields: {1: 10, 2: 30}}} where custom_field is a hashmap with configuration_ids as keys
# Note: This operation will only create custom fields and set the values of custom fields but will not save the report.
## Primarily because the call class usually has a save call after this
class CustomField::SetDistanceExpense < CustomField::SetFields

  def name
    'Expense'
  end

  def identifier
    :distance_expense
  end

  def parent_type_id
    FieldParentType.id_for(:distance_expense)
  end

end
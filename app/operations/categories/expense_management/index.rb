class Categories::ExpenseManagement::Index < Categories::Base

  def init
    self.company = user.company
    self.purpose = "expense_management"
    self.parent_type_id = FieldParentType.ids_for([:manual_expense, :card_expense, :time_expense, :distance_expense, :per_diem_expense])
  end

  def validate
    if self.purpose.blank?
      add_message :error, "Purpose cannot be blank"
    end
  end

  def process
    self.categories = self.company.categories.with_purpose(self.purpose)
    self.custom_fields = self.company.field_configurations.with_parent_type(self.parent_type_id)
  end

end
class Category::Invoice::Index < Category::Base


  def init
    self.company = user.company
    self.purpose_id = Purpose.id_for(:invoice)
    self.parent_type_id = FieldParentType.id_for(:invoice)
  end

  def validate
    if self.purpose_id.blank?
      add_message :error, "Purpose cannot be blank"
    end
  end

end
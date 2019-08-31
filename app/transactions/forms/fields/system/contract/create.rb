class Forms::Fields::System::Contract::Create < Forms::Fields::Contract::Create

  def set_custom_value
    self.custom = false
  end

end
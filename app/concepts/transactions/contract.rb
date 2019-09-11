class Transactions::Contract < Reform::Form
  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      # if err_list.is_a?(Hash)
      #   add_schema_errors(err_list)
      # elsif err_list.respond_to?(:each)
      #   err_list.each do |e|
      #     errors.add attr, e
      #   end
      # else
      #   errors.add attr, err_list
      # end
      errors.add attr, err_list
    end
  end

end
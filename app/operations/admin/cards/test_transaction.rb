class Admin::Cards::TestTransaction < Admin::Cards::IsAssigned

  def process
    super
    return if has_errors?
    credit_val = ItzCash::Credit.(user, card: selected_card, amount: 0.01)
    unless credit_val.success?
      add_message :error, credit_val.messages[:error]
    end
  end

end
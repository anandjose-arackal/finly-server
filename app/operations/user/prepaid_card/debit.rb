class User::PrepaidCard::Debit < User::PrepaidCard::Credit

  def process
    self.credit_presenter = ItzCash::Debit.(selected_user, params)
    if credit_presenter.failure?
      messages[:error] = credit_presenter.messages[:error]
    end
  end

end
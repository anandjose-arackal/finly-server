class Personalizer::Adapters::Company37::MoneyRequest37::Submit37::PreProcess < Personalizer::Adapters::Base
  attr_accessor :money_request

  def init
    self.money_request = self.op_instance.money_request
  end

  def validate
    if self.money_request.blank?
      return
    end
    # Block money request's from being submitted if expenses older than 7 days are not yet submitted
    if self.op_instance.user.expenses.unreported.date_before(7.days.ago.beginning_of_day).exists?
      add_message :error, 'You will have to submit your expenses before you can request for money'
      return
    end
  end

end
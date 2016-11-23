
class Statement::Summary < Statement::Base

  attr_accessor :items, :start_date, :end_date

  def pre_validate

  end

  def init
    load_selected_user
    if params[:start_date]
      self.start_date = params[:start_date]
    else
      self.start_date = Date.parse("01-01-1990") # arbitrarily chosen as the lower bound date
    end
    if params[:end_date]
      self.end_date = params[:end_date]
    else
      self.end_date = Date.today
    end
  end

  def authorize
    unless selected_user
      raise_unauthorized_exception
      return
    end
  end

  def process
    # items[:user_account_balance] = # needs to be calculated from wallet transactions
    # items[:]

    # amount spent from card
    load_card_transactions
  end

  private

  def load_card_transactions
    cards = selected_user.cards
    items[:atm] = items[:pos] = items[:online]
    cards.each do |card|

    end
  end

end
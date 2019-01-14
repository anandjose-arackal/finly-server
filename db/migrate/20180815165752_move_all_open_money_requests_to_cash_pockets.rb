class MoveAllOpenMoneyRequestsToCashPockets < ActiveRecord::Migration[4.2]
  def change
    money_requests = MoneyRequest.where(status_id: MoneyRequestStatus.ids_for([:open, :retracted, :rejected, :processing])).where(payment_mode: PaymentMode.id_for(:cash))
    money_requests.each do |money_request|
      pocket = money_request.user.user_pockets.cash_pockets_only.first
      money_request.update(destination_pocket_id: pocket.id)
    end
  end
end
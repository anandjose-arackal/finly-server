class UpdateBalanceHistoryFromPoller < ActiveRecord::Migration[4.2]
  def change
    result = BalanceMsgQueueLogParser.parse
    return unless result.present?
    # bal = {}
    result.each do |card_proxy, value|
      card = Card.unscoped.find_by_proxy(card_proxy)
      next unless card.present?
      user = card.user
      unless user.present?
        raise "User not found : #{card_proxy}"
      end
      last_balance = '0'
      user.user_balance_histories.includes(:card_balance).all.each do |history|
        date = DateUtils.date_formatted(history.date)
        # old_balance = history.card_balance.value.to_s
        new_balance = (value[date] or last_balance)
        last_balance = new_balance
        history.card_balance.update(value: new_balance)
        # bal[card_proxy] = {} if bal[card_proxy].nil?
        # bal[card_proxy][date] = {old_val: old_balance, new_bal: new_balance}
      end
    end
  end
end

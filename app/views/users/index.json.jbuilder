json.array!(@result.paginated_team) do |user|
  json.extract! user, :id, :email, :company_id, :mobile_number, :active, :first_name, :last_name, :verified, :name

  # Wallet
  json.finly_money do 
    json.balance user.wallet.balance.value
    json.currency do
      json.country_code user.wallet.balance.currency.country_code
      json.symbol user.wallet.balance.currency.symbol
    end
  end

  # Cards
  json.cards do
    json.array!(user.cards) do |card|
      json.active card.active
      json.card_program_id card.card_program.id
      json.card_program_name card.card_program.name
      json.eligibility  card.card_eligibility.value
      # Balance for only expense card
      if card.card_program.id == 1
        json.balance card.card_balance.value
      end
      json.currency do
        json.country_code card.card_balance.currency.country_code
        json.symbol card.card_balance.currency.symbol
      end
    end
  end
end
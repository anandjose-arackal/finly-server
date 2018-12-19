json.result do
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

    accounts = user.cards + user.user_pockets + [user.wallet]

    json.accounts do
      json.array!(accounts) do |account|
        case account.class.name
          when "UserPocket"
            json.id account.id
            json.name account.name
            json.type 'pocket'
            case account.user_pocket_type_id
              when UserPocketType.id_for(:cash)
                adapter = AccountManager::CashPockets::CashPocketsAdapter.new(account)
                json.creditable true
                json.display_balance true
              when UserPocketType.id_for(:credit_card)
                adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(account)
                json.creditable false
              when UserPocketType.id_for(:reimbursement)
                adapter = AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(account)
                json.creditable false
              when UserPocketType.id_for(:paid_by_company)
                adapter = AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(account)
                json.creditable false
              else
                adapter = nil
            end
            json.amount do
              json.value adapter.balance(display_balance: true)
              json.currency account.base_currency
            end

          when "Card"
            json.id account.id
            json.name account.proxy
            json.type 'card'
            json.amount do
              json.value account.card_balance&.value
              json.currency Currency.first
            end

          when "UserWallet"
            json.id account.id
            json.name "#{account.user.name}'s Finly Money"
            json.type 'finly_money'
            adapter = AccountManager::Wallet::WalletAdapter.new(account)
            json.amount do
              json.value adapter.balance
              json.currency Currency.first
            end
        end
      end
    end

    # # Cards
    # json.cards do
    #   json.array!(user.cards) do |card|
    #     json.active card.active
    #     json.card_program_id card.card_program.id
    #     json.card_program_name card.card_program.name
    #     eligibility = (card.card_eligibility.value rescue 0)
    #     json.eligibility eligibility
    #     # Balance for only expense card
    #     if card.card_program.id == 1
    #       balance = (card.card_balance.value rescue 0)
    #       json.balance balance
    #     end
    #     json.currency do
    #       country_code = (card.card_balance.currency.country_code rescue nil)
    #       json.country_code country_code
    #       symbol = (card.card_balance.currency.symbol rescue nil)
    #       json.symbol symbol
    #     end
    #   end
    # end

    # user roles
    json.roles do
      json.array!(user.expense_management_roles) do |role|
        json.id role.id
        json.name UserRole.name_for(role.id)
      end
    end

    # user status
    json.status user.status

    # # user accounts
    # json.accounts do
    #   json.array!(user.user_pockets) do |pocket|
    #     json.name pocket.name
    #     json.id pocket.id
    #     case pocket.user_pocket_type_id
    #       when UserPocketType.id_for(:cash)
    #         adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
    #         json.creditable true
    #         json.display_balance true
    #       when UserPocketType.id_for(:credit_card)
    #         adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(pocket)
    #         json.creditable false
    #       when UserPocketType.id_for(:reimbursement)
    #         adapter = AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(pocket)
    #         json.creditable false
    #       when UserPocketType.id_for(:paid_by_company)
    #         adapter = AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(pocket)
    #         json.creditable false
    #       else
    #         adapter = nil
    #     end
    #     json.balance adapter.balance(display_balance: true)
    #     currency = pocket.base_currency
    #     json.base_currency do
    #       json.symbol currency&.symbol
    #       json.country_code currency&.country_code
    #       json.id currency&.id
    #     end
    #   end
    # end
  end
end

json.count @result.count
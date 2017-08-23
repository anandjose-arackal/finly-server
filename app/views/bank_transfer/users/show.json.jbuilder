json.user do
  json.extract! @result.selected_user, :email, :name, :mobile_number,
              :address_1, :address_2
  json.gender @result.selected_user.gender_name

end

json.actions @result.actions

json.bank_accounts do
  json.array!(@result.selected_user.bank_accounts) do |bank_account|
    json.account do
      json.account_number bank_account.account_number
      json.ifsc bank_account.ifsc
      json.name bank_account.name
      json.id bank_account.id
    end
    json.account_owner do
      json.owner_name bank_account.account_owner.name

      json.email bank_account.account_owner.email
      json.mobile_number bank_account.account_owner.mobile_number
    end
  end
end

json.subscriptions do
  json.show_config @result.selected_user.company.more_than_one_subscription?
  json.expense_management @result.user_panel_subscription.expense_management
  json.disburse @result.user_panel_subscription.disburse
  json.yes_bank_account_transfer @result.user_panel_subscription.yes_bank_account_transfer
end

json.wallet do
  wallet_adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(@result.selected_user.bank_wallet)
  json.balance wallet_adapter.balance
end


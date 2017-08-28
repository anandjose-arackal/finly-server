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

json.role do
  json.admin @result.roles[:admin]
  json.finance_manager @result.roles[:finance_manager]
  json.manager @result.roles[:manager]
  json.initiator @result.roles[:initiator]
  # since only admins can see this screen, they can edit the fields by default
end

json.mapping @result.mapping.each do |mapping|
  json.company_default mapping[:company_default]
  if mapping[:policy]
    json.policy do
      json.id mapping[:policy].id
      json.name mapping[:policy].name
    end
  end
  [:default, :conditional_manager, :conditional_finance_manager,
   :conditional_approves_to, :conditional_approves_finance_to].each do |key|
    json.set! key do
      maps = mapping[key]
      next if maps.blank?
      if key == :default
        map = maps.first rescue nil
        next if map.blank?
        json.mapping_id map.id
        if map.greater_than_amount_id.present?
          json.greater_than_amount do
            # json.id map.greater_than_amount_id
            json.value map.greater_than_amount.value
            json.currency_id map.greater_than_amount.currency_id
          end
        end
        [:manager, :finance_manager, :approves_to, :approves_finance_to].each do |k|
          if map.send("#{k}_id").present?
            json.set! k do
              json.id map.send("#{k}_id")
              json.name map.send(k).name
            end
          end
        end
      else
        json.array! maps do |map|
          json.mapping_id map.id
          if map.greater_than_amount_id.present?
            json.greater_than_amount do
              # json.id map.greater_than_amount_id
              json.value map.greater_than_amount.value
              json.currency_id map.greater_than_amount.currency_id
            end
          end
          [:manager, :finance_manager, :approves_to, :approves_finance_to].each do |k|
            if map.send("#{k}_id").present?
              json.set! k do
                json.id map.send("#{k}_id")
                json.name map.send(k).name
              end
            end
          end
        end
      end
    end
  end
end


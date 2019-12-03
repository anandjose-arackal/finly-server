class AccountingExports::Master::BaseMaster
  include EventBus::Bus

  subscribers_path "#{Rails.root}/app/operations/accounting_exports/master"
end
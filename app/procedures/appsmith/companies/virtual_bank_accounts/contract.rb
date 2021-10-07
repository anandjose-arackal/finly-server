class Appsmith::Companies::VirtualBankAccounts::Contract < Reform::Form

    property :purpose
    property :receiving_account_id
    property :receiveing_account_type

    validates :purpose, presence: true
    validates :receiving_account_id, presence: true
    validates :receiving_account_type, presence: true, :inclusion => {:in => [YesBankCompanyAccount.name, VendorPaymentWallet.name, CashOnHand.name, UtilityBillsAccount.name]}

end
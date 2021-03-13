class UpdateTenants
  def self.run
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    ActsAsTenant.without_tenant do
      # 66741
      UserPanelSubscription.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserPanelSubscription.import records, on_duplicate_key_update: [:company_id]
      end

      # 534442
      UserRoleMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserRoleMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 71291
      UserProfile.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserProfile.import records, on_duplicate_key_update: [:company_id]
      end

      # 328506
      PolicyUserRole.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        PolicyUserRole.import records, on_duplicate_key_update: [:company_id]
      end

      # 61863
      UserWallet.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserWallet.import records, on_duplicate_key_update: [:company_id]
      end

      # 61786
      VendorPaymentWallet.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        VendorPaymentWallet.import records, on_duplicate_key_update: [:company_id]
      end

      # 183410
      UserPocket.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserPocket.import records, on_duplicate_key_update: [:company_id]
      end

      # 30643
      PolicyDepartmentMapping.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        PolicyDepartmentMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # Here
      # 61787
      EnforcePolicy.find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.enforceable_type == 'Company'
            record.company_id = record.enforceable&.id
          else
            record.company_id = record.enforceable&.company_id
          end
        end
        EnforcePolicy.import records, on_duplicate_key_update: [:company_id]
      end

      # 115417
      PolicyLocationMapping.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        PolicyLocationMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 3392475
      DocumentLevelReviewerMapping.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        DocumentLevelReviewerMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 288950
      ProcurementStatusTaggable.includes(:procurement).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.procurement&.company_id
        end
        ProcurementStatusTaggable.import records, on_duplicate_key_update: [:company_id]
      end

      # 3640
      FieldParentMapping.includes(:field_configuration).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.field_configuration&.company_id
        end
        FieldParentMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 38961
      PurchaseRequestItem.includes(:purchase_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.purchase_request&.company_id
        end
        PurchaseRequestItem.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 61785
      CashOnHand.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        CashOnHand.import records, on_duplicate_key_update: [:company_id]
      end

      # 125150
      GstinLocation.includes(:vendor).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.vendor&.company_id
        end
        GstinLocation.import records, on_duplicate_key_update: [:company_id]
      end

      # 274
      UserGroupItem.includes(:user_group).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user_group&.company_id
        end
        UserGroupItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 50
      UserTeamGroupItemMapping.includes(:user_group).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user_group&.company_id
        end
        UserTeamGroupItemMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 324704
      UserIp.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserIp.import records, on_duplicate_key_update: [:company_id]
      end

      # 124744
      UserAgentClient.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserAgentClient.import records, on_duplicate_key_update: [:company_id]
      end

      # 18727
      BudgetGroupCriteriaMapping.includes(:budget_group_criterium).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget_group_criterium&.company_id
        end
        BudgetGroupCriteriaMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 26144
      BudgetConsumption.includes(:budget).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget&.company_id
        end
        BudgetConsumption.import records, on_duplicate_key_update: [:company_id]
      end

      # 14252657
      CustomField.includes(:field_configuration).find_in_batches(batch_size: 1000) do |custom_fields|
        custom_fields.each do |custom_field|
          custom_field.company_id = custom_field.field_configuration.company_id
        end
        CustomField.import custom_fields, on_duplicate_key_update: [:company_id]
      end

      # Here
      # 6127945
      BudgetTrail.includes(:entity).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.entity&.company_id
        end
        BudgetTrail.import records, on_duplicate_key_update: [:company_id]
      end

      # 1216912
      Expense.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        Expense.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 90449
      PurchaseOrderItem.includes(:purchase_order).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.purchase_order&.company_id
        end
        PurchaseOrderItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 367776
      InvoiceLineItem.includes(:invoice).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.invoice&.company_id
        end
        InvoiceLineItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 668
      Booking.includes(:travel_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.travel_request&.company_id
        end
        Booking.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 23809
      MoneyRequest.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        MoneyRequest.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 601510
      Receipt.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        Receipt.import records, on_duplicate_key_update: [:company_id]
      end

      # 799
      TravelRequestDestination.includes(:travel_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.travel_request&.company_id
        end
        TravelRequestDestination.import records, on_duplicate_key_update: [:company_id]
      end

      # 5232
      PolicyFieldMapping.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        PolicyFieldMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 4421831
      Trail.includes(:action_user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.action_user&.company_id
        end
        Trail.import records, on_duplicate_key_update: [:company_id]
      end

      # 2877951
      FieldDropDownSelection.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldDropDownSelection.import records, on_duplicate_key_update: [:company_id]
      end

      # 6986
      BudgetRule.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        BudgetRule.import records, on_duplicate_key_update: [:company_id]
      end

      # 8162
      BudgetRuleCategoryMapping.includes(:budget_rule).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget_rule&.company_id
        end
        BudgetRuleCategoryMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 10974
      BudgetRuleFieldMapping.includes(:budget_rule).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget_rule&.company_id
        end
        BudgetRuleFieldMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 653527
      ReportComment.includes(:report).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.report&.company_id
        end
        ReportComment.import records, on_duplicate_key_update: [:company_id]
      end

      # 613169
      MoneyRequestItem.includes(:money_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.money_request&.company_id
        end
        MoneyRequestItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 68838
      MoneyRequestComment.includes(:money_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.money_request&.company_id
        end
        MoneyRequestComment.import records, on_duplicate_key_update: [:company_id]
      end

      # 2544
      DistanceExpenseConfig.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        DistanceExpenseConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 2544
      TimeExpenseConfig.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        TimeExpenseConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 1890
      VehicleRate.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        VehicleRate.import records, on_duplicate_key_update: [:company_id]
      end

      # 2544
      PerDiemExpenseConfig.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        PerDiemExpenseConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 189
      PerDiem.includes(:configurable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.configurable&.company_id
        end
        PerDiem.import records, on_duplicate_key_update: [:company_id]
      end

      # 921
      ParentDependentFieldConfigurationMapping.includes(:dependent_field_configuration).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.dependent_field_configuration&.company_id
        end
        ParentDependentFieldConfigurationMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 368509
      SystemMessage.includes(:messagable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.messagable&.company_id
        end
        SystemMessage.import records, on_duplicate_key_update: [:company_id]
      end

      # 113523
      DuplicateExpenseMapping.includes(:expense).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.expense&.company_id
        end
        DuplicateExpenseMapping.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 668298
      ManualExpense.includes(:expense).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.expense&.company_id
        end
        ManualExpense.import records, on_duplicate_key_update: [:company_id]
      end

      # 269045
      CardExpense.includes(:expense).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.expense&.company_id
        end
        CardExpense.import records, on_duplicate_key_update: [:company_id]
      end

      # 266055
      DistanceExpense.includes(:expense).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.expense&.company_id
        end
        DistanceExpense.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 49
      TimeExpense.includes(:expense).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.expense&.company_id
        end
        TimeExpense.import records, on_duplicate_key_update: [:company_id]
      end

      # 14427
      PerDiemExpense.includes(:expense).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.expense&.company_id
        end
        PerDiemExpense.import records, on_duplicate_key_update: [:company_id]
      end

      # 548
      BookingFlight.includes(:booking).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.booking&.company_id
        end
        BookingFlight.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 32
      BookingTrain.includes(:booking).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.booking&.company_id
        end
        BookingTrain.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 31
      BookingBus.includes(:booking).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.booking&.company_id
        end
        BookingBus.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 55
      BookingCarRental.includes(:booking).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.booking&.company_id
        end
        BookingCarRental.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 51
      BookingHotel.includes(:booking).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.booking&.company_id
        end
        BookingHotel.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 0
      BookingOther.includes(:booking).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.booking&.company_id
        end
        BookingOther.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 161
      RateContractLineItem.includes(:rate_contract).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.rate_contract&.company_id
        end
        RateContractLineItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 10736795
      FieldText.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldText.import records, on_duplicate_key_update: [:company_id]
      end

      # 630019
      CardTransaction.includes(:card).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.card&.company_id
        end
        CardTransaction.import records, on_duplicate_key_update: [:company_id]
      end

      # 61785
      AutoSubmitConfig.includes(:submitable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.submitable&.company_id
        end
        AutoSubmitConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 113
      KycDocument.includes(:company_kyc).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.company_kyc&.company_id
        end
        KycDocument.import records, on_duplicate_key_update: [:company_id]
      end

      # 14
      FieldCustomization.includes(:scopable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.scopable&.id
        end
        FieldCustomization.import records, on_duplicate_key_update: [:company_id]
      end

      # 78870
      ProcurementComment.includes(:parent_commentable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.parent_commentable&.company_id
        end
        ProcurementComment.import records, on_duplicate_key_update: [:company_id]
      end

      # 13515
      Quotation.includes(:purchase_order).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.purchase_order&.company_id
        end
        Quotation.import records, on_duplicate_key_update: [:company_id]
      end

      # 1870
      UserDepartmentMapping.includes(:department).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.department&.company_id
        end
        UserDepartmentMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 18
      UserDelegateMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserDelegateMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 112232
      UserBalanceHistory.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserBalanceHistory.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      UserBranchLocationMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserBranchLocationMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      UserDropDownItemMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserDropDownItemMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      UserFieldMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserFieldMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 564
      UserGroupItemMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserGroupItemMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 509600
      UserLoginTrack.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserLoginTrack.import records, on_duplicate_key_update: [:company_id]
      end

      # 261045
      UserManagerMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserManagerMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      UserTag.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        UserTag.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      UserWalletTrack.includes(:user_wallet).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user_wallet&.company_id
        end
        UserWalletTrack.import records, on_duplicate_key_update: [:company_id]
      end

      # 0 UserWalletTrackAction
      UserWalletTrack.includes(:user_wallet).find_each do |record|
        if record.user_wallet.present? and record.user_wallet_track_action.present?
          record.user_wallet_track_action.update_column(:company_id, record.user_wallet.company_id)
        end
      end

      # 431
      Address.includes(:parent).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.parent&.company_id
        end
        Address.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      ApprovalRoute.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        ApprovalRoute.import records, on_duplicate_key_update: [:company_id]
      end

      # 45
      Authentication.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        Authentication.import records, on_duplicate_key_update: [:company_id]
      end

      # 61785
      AutoReloadConfig.includes(:reloadable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.reloadable&.company_id
        end
        AutoReloadConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 61785
      BalanceSheet.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        BalanceSheet.import records, on_duplicate_key_update: [:company_id]
      end

      # 14904 BankAccountMaster, 682004 BankAccount
      BankAccount.where.not(bank_account_master_id: nil, company_id: nil).includes(:company).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.company.present? and record.bank_account_master.present?
            record.bank_account_master.update_column(:company_id, record.company_id)
          end
        end
      end

      # 1333661
      BankPaymentRequestComment.includes(:bank_payment_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.bank_payment_request&.company_id
        end
        BankPaymentRequestComment.import records, on_duplicate_key_update: [:company_id]
      end

      # 3607952
      BankPaymentRequestTrail.includes(:bank_payment_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.bank_payment_request&.company_id
        end
        BankPaymentRequestTrail.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      BbpsSubscriptionField.includes(:subscription).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.subscription&.company_id
        end
        BbpsSubscriptionField.import records, on_duplicate_key_update: [:company_id]
      end

      # 3580
      BbpsSubscriptionPoc.includes([:subscription, :user]).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.subscription.present?
            record.company_id = record.subscription&.company_id
          elsif record.user.present?
            record.company_id = record.user&.company_id
          end
        end
        BbpsSubscriptionPoc.import records, on_duplicate_key_update: [:company_id]
      end

      # 57
      BookingRequest.includes(:travel_request_destination).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.travel_request_destination&.company_id
        end
        BookingRequest.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 11
      BookingRestaurant.includes(:booking).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.booking&.company_id
        end
        BookingRestaurant.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 2257
      BudgetCriteriaMapping.includes(:budget).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget&.company_id
        end
        BudgetCriteriaMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 3289
      BudgetModificationTrail.includes(:budget).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget&.company_id
        end
        BudgetModificationTrail.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      BudgetRuleBranchLocationMapping.includes(:budget_rule).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget_rule&.company_id
        end
        BudgetRuleBranchLocationMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 2536
      BudgetRuleDepartmentMapping.includes(:budget_rule).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget_rule&.company_id
        end
        BudgetRuleDepartmentMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 10111
      BudgetRuleExpenseTypeMapping.includes(:budget_rule).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.budget_rule&.company_id
        end
        BudgetRuleExpenseTypeMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 77
      CardAssignRequestTrack.includes(:card_assign_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.card_assign_request&.company_id
        end
        CardAssignRequestTrack.import records, on_duplicate_key_update: [:company_id]
      end

      # 51
      CardBalanceHistory.includes(:card).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.card&.company_id
        end
        CardBalanceHistory.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      CardConfiguration.includes(:prepaid_card).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.prepaid_card&.company_id
        end
        CardConfiguration.import records, on_duplicate_key_update: [:company_id]
      end

      # 2523
      CardExpenseConfig.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        CardExpenseConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 14193
      CardRestriction.includes(:card).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.card&.company_id
        end
        CardRestriction.import records, on_duplicate_key_update: [:company_id]
      end

      # 85158
      CardLimit.includes(:card_restriction).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.card_restriction&.company_id
        end
        CardLimit.import records, on_duplicate_key_update: [:company_id]
      end

      # 2523
      CashExpenseConfig.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        CashExpenseConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 92
      CompanyKycTrail.includes(:company_kyc).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.company_kyc&.company_id
        end
        CompanyKycTrail.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      CompanyLocationDepartment.includes([:branch_location, :company_department]).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.branch_location.present?
            record.company_id = record.branch_location&.company_id
          elsif record.company_department.present?
            record.company_id = record.company_department&.company_id
          end
        end
        CompanyLocationDepartment.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      Contact.includes(:contactable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.contactable&.company_id
        end
        Contact.import records, on_duplicate_key_update: [:company_id]
      end

      # 60
      CreditNoteAdjustment.includes([:invoice, :credit_note]).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.invoice.present?
            record.company_id = record.invoice&.company_id
          elsif record.credit_note.present?
            record.company_id = record.credit_note&.company_id
          end
        end
        CreditNoteAdjustment.import records, on_duplicate_key_update: [:company_id]
      end

      # 153
      CreditNoteItem.includes(:parent).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.parent&.company_id
        end
        CreditNoteItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 270
      CustomExportConfiguration.find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.configurable_type == 'Company'
            record.company_id = record.configurable_id
          else
            record.company_id = record.configurable&.company_id
          end
        end
        CustomExportConfiguration.import records, on_duplicate_key_update: [:company_id]
      end

      # 152
      CustomerAttachment.includes(:customer).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.customer&.company_id
        end
        CustomerAttachment.import records, on_duplicate_key_update: [:company_id]
      end

      # 239
      CustomerAccount.includes(:customer).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.customer&.company_id
        end
        CustomerAccount.import records, on_duplicate_key_update: [:company_id]
      end

      # 19
      CustomerAccountTransaction.includes(:customer_account).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.customer_account&.company_id
        end
        CustomerAccountTransaction.import records, on_duplicate_key_update: [:company_id]
      end

      # 225753
      DocumentSlice.includes(:receipt).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.receipt&.company_id
        end
        DocumentSlice.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      DocumentMessage.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        DocumentMessage.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      DocumentMessageReceipt.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        DocumentMessageReceipt.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      DocumentItem.includes(:inventory_line_item).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.inventory_line_item.present?
            record.company_id = record.inventory_line_item&.company_id
          elsif record.parent_document.present?
            record.company_id = record.parent_document&.company_id
          end
        end
        DocumentItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 512155
      EmailAuthorization.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        EmailAuthorization.import records, on_duplicate_key_update: [:company_id]
      end

      # 4909
      ReceiptEmail.includes(:expense).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.expense&.company_id
        end
        ReceiptEmail.import records, on_duplicate_key_update: [:company_id]
      end

      # 3957
      ExpenseDataExtract.includes(:extractable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.extractable&.company_id
        end
        ExpenseDataExtract.import records, on_duplicate_key_update: [:company_id]
      end

      # 32165
      ExpenseRule.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        ExpenseRule.import records, on_duplicate_key_update: [:company_id]
      end

      # 270
      FeatureSubscription.find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.subscribable_id
        end
        FeatureSubscription.import records, on_duplicate_key_update: [:company_id]
      end

      # 44
      Feedback.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        Feedback.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      FieldAmount.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldAmount.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      FieldBoolean.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldBoolean.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      FieldDateTime.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldDateTime.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      FieldDate.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldDate.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      FieldDecimal.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldDecimal.import records, on_duplicate_key_update: [:company_id]
      end

      # 13481
      FieldDropDownItem.includes(:field_configuration).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.field_configuration&.company_id
        end
        FieldDropDownItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 410
      FieldMultiselectItem.includes(:field_configuration).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.field_configuration&.company_id
        end
        FieldMultiselectItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 65943
      FieldMultiselectSelection.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldMultiselectSelection.import records, on_duplicate_key_update: [:company_id]
      end

      # 81593
      FieldMultiselectSelectionItem.includes(:field_multiselect_selection).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.field_multiselect_selection&.company_id
        end
        FieldMultiselectSelectionItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      FieldNumber.includes(:custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.custom_field&.company_id
        end
        FieldNumber.import records, on_duplicate_key_update: [:company_id]
      end

      # 354003
      FormCustomField.includes(:form).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.form&.company_id
        end
        FormCustomField.import records, on_duplicate_key_update: [:company_id]
      end

      # 52014
      CustomFieldAttachment.includes(:form_custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.form_custom_field&.company_id
        end
        CustomFieldAttachment.import records, on_duplicate_key_update: [:company_id]
      end

      # 1351
      CustomFieldSelection.includes(:form_custom_field).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.form_custom_field&.company_id
        end
        CustomFieldSelection.import records, on_duplicate_key_update: [:company_id]
      end

      # 10063 Gstin, 125150 GstinLocation
      GstinLocation.where.not(gstin_id: nil).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.gstin_master.present?
            record.gstin_master.update_column(:company_id, record.company_id)
          end
        end
      end

      # 19237
      IndividualKycTrack.includes(:individual_kyc).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.individual_kyc&.company_id
        end
        IndividualKycTrack.import records, on_duplicate_key_update: [:company_id]
      end

      # 205
      InvoiceTransactionMapping.includes(:invoice).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.invoice&.company_id
        end
        InvoiceTransactionMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 100687
      InwardDocumentItem.includes(:inward_document).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.inward_document&.company_id
        end
        InwardDocumentItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      ItzCashDmtSender.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        ItzCashDmtSender.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      ItzCashDmtBeneficiary.includes(:itz_cash_dmt_sender).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.itz_cash_dmt_sender&.company_id
        end
        ItzCashDmtBeneficiary.import records, on_duplicate_key_update: [:company_id]
      end

      # 69010
      LevelReviewerMapping.includes(:reviewer).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.reviewer&.company_id
        end
        LevelReviewerMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 220824
      LevelUserReviewerMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        LevelUserReviewerMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      LoginAgreementMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        LoginAgreementMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 376
      ManagerSummaryMailConfig.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        ManagerSummaryMailConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # 96214
      MapLocationUserQuery.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        MapLocationUserQuery.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      MccCategoryMapping.includes(:category).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.category&.company_id
        end
        MccCategoryMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 2203
      MoneyRequestProcessorMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        MoneyRequestProcessorMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 30229
      MoneyRequestTrack.includes(:money_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.money_request&.company_id
        end
        MoneyRequestTrack.import records, on_duplicate_key_update: [:company_id]
      end

      # 3148944
      Notification.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        Notification.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      NotifierTypeConfiguration.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        NotifierTypeConfiguration.import records, on_duplicate_key_update: [:company_id]
      end

      # 302
      OutwardInvoiceTrail.includes(:invoice).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.invoice&.company_id
        end
        OutwardInvoiceTrail.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      PaymentAgreementEscalation.includes(:payment_agreement).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.payment_agreement&.company_id
        end
        PaymentAgreementEscalation.import records, on_duplicate_key_update: [:company_id]
      end

      # 77670
      PaymentOrderAttachment.includes(:payment_order).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.payment_order&.company_id
        end
        PaymentOrderAttachment.import records, on_duplicate_key_update: [:company_id]
      end

      # 2392
      PolicyConfiguration.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        PolicyConfiguration.import records, on_duplicate_key_update: [:company_id]
      end

      # 132811
      PolicyUserMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        PolicyUserMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 2016
      PostOperationAction.includes(:post_operatable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.post_operatable&.company_id
        end
        PostOperationAction.import records, on_duplicate_key_update: [:company_id], validate: false
      end

      # 6983
      ReceiptEmailAttachment.includes(:receipt_email).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.receipt_email&.company_id
        end
        ReceiptEmailAttachment.import records, on_duplicate_key_update: [:company_id]
      end

      # 39932
      ReportProcessorGroupMapping.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        ReportProcessorGroupMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 81475
      ReportTrack.includes(:report).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.report&.company_id
        end
        ReportTrack.import records, on_duplicate_key_update: [:company_id]
      end

      # 42
      ResourceTemplate.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        ResourceTemplate.import records, on_duplicate_key_update: [:company_id]
      end

      # 24988
      ReviewalLevel.includes(:policy).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.policy&.company_id
        end
        ReviewalLevel.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      TranscribedExpense.includes(:receipt).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.receipt&.company_id
        end
        TranscribedExpense.import records, on_duplicate_key_update: [:company_id]
      end

      # 774
      TravelRequestComment.includes(:travel_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.travel_request&.company_id
        end
        TravelRequestComment.import records, on_duplicate_key_update: [:company_id]
      end

      # 352
      TravelRequestTrail.includes(:travel_request).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.travel_request&.company_id
        end
        TravelRequestTrail.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      TripRoute.includes(:trip).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.trip&.company_id
        end
        TripRoute.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      TripPassenger.includes(:trip).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.trip&.company_id
        end
        TripPassenger.import records, on_duplicate_key_update: [:company_id]
      end

      # 38629220
      UserSessionEvent.includes(:user_session).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user_session&.company_id
        end
        UserSessionEvent.import records, on_duplicate_key_update: [:company_id]
      end

      # 10
      AdminSummaryMailConfig.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        AdminSummaryMailConfig.import records, on_duplicate_key_update: [:company_id]
      end

      # Here
      # MacroSchedule.includes(:macro).find_each do |record|
      #   if record.macro.present?
      #     record.update_column(:company_id, record.macro.company_id)
      #   end
      # end

      # MacroRoute.includes(:macro).find_each do |record|
      #   if record.macro.present?
      #     record.update_column(:company_id, record.macro.company_id)
      #   end
      # end

      # MacroJob.includes(:macro).find_each do |record|
      #   if record.macro.present?
      #     record.update_column(:company_id, record.macro.company_id)
      #   end
      # end

      # MacroJobLog.includes(:macro).find_each do |record|
      #   if record.macro.present?
      #     record.update_column(:company_id, record.macro.company_id)
      #   end
      # end

      # 318 GeneralInvoice - Updating 22077 InvoiceFrequency
      GeneralInvoice.where.not(invoice_frequency_id: nil).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.invoice_frequency.update_column(:company_id, record.company_id)
        end
      end

      # 16825 RentalInvoice - Updating 22077 InvoiceFrequency
      RentalInvoice.where.not(invoice_frequency_id: nil).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.invoice_frequency.update_column(:company_id, record.company_id)
        end
      end

      # 0
      PaymentTrail.includes(:macro).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.initiating_account.present? && record.initiating_account.respond_to?(:company)
            record.company_id = record.initiating_account&.company_id
          elsif record.initiating_user.present? && record.initiating_user.respond_to?(:company)
            record.company_id = record.initiating_user&.company_id
          end
        end
        PaymentTrail.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      ProcurementCharge.includes(:chargable).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.chargable&.company_id
        end
        ProcurementCharge.import records, on_duplicate_key_update: [:company_id]
      end

      # 497
      ReceiptEmailParseFailure.includes(:user).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.user&.company_id
        end
        ReceiptEmailParseFailure.import records, on_duplicate_key_update: [:company_id]
      end

      # 2137
      VirtualAccountTransaction.includes(:virtual_account).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.virtual_account&.company_id
        end
        VirtualAccountTransaction.import records, on_duplicate_key_update: [:company_id]
      end

      # 6378
      SystemLog.includes(:log_resource).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.log_resource&.company_id
        end
        SystemLog.import records, on_duplicate_key_update: [:company_id]
      end

      # 0 TaskSchedule, 0 TaskWorkflow
      TaskWorkflow.where.not(task_schedule_id: nil).find_each do |record|
        record.task_schedule.update_column(:company_id, record.company_id)
      end

      # 0 TaskFileManagerAction, 0 TaskWorkflow
      TaskWorkflow.find_each do |tw|
        tw.file_manager_actions.each do |record|
          record.update_column(:company_id, tw.company_id)
        end
      end

      # 0
      TaxPerItem.includes(:tax_rate).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.tax_rate&.company_id
        end
        TaxPerItem.import records, on_duplicate_key_update: [:company_id]
      end

      # 57 TimeObject, 49 TimeExpense
      TimeExpense.where.not(time_object_id: nil).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.time_object.update_column(:company_id, record.company_id)
        end
      end

      # 740
      TravelMember.includes([:booking, :booking_request]).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          if record.booking.present?
            record.company_id = record.booking&.company_id
          elsif record.booking_request.present?
            record.company_id = record.booking_request&.company_id
          end
        end
        TravelMember.import records, on_duplicate_key_update: [:company_id]
      end

      # 486751
      VendorAccount.includes(:vendor).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.vendor&.company_id
        end
        VendorAccount.import records, on_duplicate_key_update: [:company_id]
      end

      # 0
      VendorAccountTransaction.includes(:vendor_account).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.vendor_account&.company_id
        end
        VendorAccountTransaction.import records, on_duplicate_key_update: [:company_id]
      end

      # 66955
      VendorAttachment.includes(:yes_bank_vendor).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.yes_bank_vendor&.company_id
        end
        VendorAttachment.import records, on_duplicate_key_update: [:company_id]
      end

      # 1701
      VendorTdsRate.includes(:vendor).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.vendor&.company_id
        end
        VendorTdsRate.import records, on_duplicate_key_update: [:company_id]
      end

      # 1
      WebHookEventMapping.includes(:web_hook).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.web_hook&.company_id
        end
        WebHookEventMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 10
      FormChoiceDependencyMapping.includes(:dependency).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.dependency&.company_id
        end
        FormChoiceDependencyMapping.import records, on_duplicate_key_update: [:company_id]
      end

      # 44
      ExportTemplateUserRoleMapping.includes(:template).find_in_batches(batch_size: 1000) do |records|
        records.each do |record|
          record.company_id = record.template&.company_id
        end
        ExportTemplateUserRoleMapping.import records, on_duplicate_key_update: [:company_id]
      end
    end
  end
end

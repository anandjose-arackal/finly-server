class UpdateTenants
  # TODO: need to update script to fetch in batches and do bulk updates
  def self.run
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    ActsAsTenant.without_tenant do
      UserPanelSubscription.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserRoleMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserProfile.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PolicyUserRole.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserWallet.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      VendorPaymentWallet.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserPocket.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PolicyDepartmentMapping.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      EnforcePolicy.find_each do |record|
        if record.enforceable.present?
          if record.enforceable_type == 'Company'
            record.update_column(:company_id, record.enforceable.id)
          else
            record.update_column(:company_id, record.enforceable.company_id)
          end
        end
      end

      PolicyLocationMapping.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      DocumentLevelReviewerMapping.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      ProcurementStatusTaggable.find_each do |record|
        if record.procurement.present?
          record.update_column(:company_id, record.procurement.company_id)
        end
      end

      FieldParentMapping.find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      PurchaseRequestItem.find_each do |record|
        if record.purchase_request.present?
          record.update_column(:company_id, record.purchase_request.company_id)
        end
      end

      CashOnHand.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      GstinLocation.find_each do |record|
        if record.vendor.present?
          record.update_column(:company_id, record.vendor.company_id)
        end
      end

      UserGroupItem.find_each do |record|
        if record.user_group.present?
          record.update_column(:company_id, record.user_group.company_id)
        end
      end

      UserTeamGroupItemMapping.find_each do |record|
        if record.user_group.present?
          record.update_column(:company_id, record.user_group.company_id)
        end
      end

      UserIp.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserAgentClient.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      BudgetGroupCriteriaMapping.find_each do |record|
        if record.budget_group_criterium.present?
          record.update_column(:company_id, record.budget_group_criterium.company_id)
        end
      end

      BudgetConsumption.find_each do |record|
        if record.budget.present?
          record.update_column(:company_id, record.budget.company_id)
        end
      end

      CustomField.find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      BudgetTrail.find_each do |record|
        if record.entity.present?
          record.update_column(:company_id, record.entity.company_id)
        end
      end

      Expense.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PurchaseOrderItem.find_each do |record|
        if record.purchase_order.present?
          record.update_column(:company_id, record.purchase_order.company_id)
        end
      end

      InvoiceLineItem.find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        end
      end

      Booking.find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      MoneyRequest.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      Receipt.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      TravelRequestDestination.find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      PolicyFieldMapping.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      Trail.find_each do |record|
        if record.action_user.present?
          record.update_column(:company_id, record.action_user.company_id)
        end
      end

      FieldDropDownSelection.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      BudgetRule.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      BudgetRuleCategoryMapping.find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      BudgetRuleFieldMapping.find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      ReportComment.find_each do |record|
        if record.report.present?
          record.update_column(:company_id, record.report.company_id)
        end
      end

      MoneyRequestItem.find_each do |record|
        if record.money_request.present?
          record.update_column(:company_id, record.money_request.company_id)
        end
      end

      MoneyRequestComment.find_each do |record|
        if record.money_request.present?
          record.update_column(:company_id, record.money_request.company_id)
        end
      end

      DistanceExpenseConfig.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      TimeExpenseConfig.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      VehicleRate.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      PerDiemExpenseConfig.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      PerDiem.find_each do |record|
        if record.configurable.present?
          record.update_column(:company_id, record.configurable.company_id)
        end
      end

      ParentDependentFieldConfigurationMapping.find_each do |record|
        if record.dependent_field_configuration.present?
          record.update_column(:company_id, record.dependent_field_configuration.company_id)
        end
      end

      SystemMessage.find_each do |record|
        if record.messagable.present?
          record.update_column(:company_id, record.messagable.company_id)
        end
      end

      DuplicateExpenseMapping.find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      ManualExpense.find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      CardExpense.find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      DistanceExpense.find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      TimeExpense.find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      PerDiemExpense.find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      BookingFlight.find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingTrain.find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingBus.find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingCarRental.find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingHotel.find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingOther.find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      RateContractLineItem.find_each do |record|
        if record.rate_contract.present?
          record.update_column(:company_id, record.rate_contract.company_id)
        end
      end

      FieldText.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      CardTransaction.find_each do |record|
        if record.card.present?
          record.update_column(:company_id, record.card.company_id)
        end
      end

      AutoSubmitConfig.find_each do |record|
        if record.submitable.present?
          record.update_column(:company_id, record.submitable.company_id)
        end
      end

      KycDocument.find_each do |record|
        if record.company_kyc.present?
          record.update_column(:company_id, record.company_kyc.company_id)
        end
      end

      FieldCustomization.find_each do |record|
        if record.scopable.present?
          record.update_column(:company_id, record.scopable.id)
        end
      end

      ProcurementComment.find_each do |record|
        if record.parent_commentable.present?
          record.update_column(:company_id, record.parent_commentable.company_id)
        end
      end

      Quotation.find_each do |record|
        if record.purchase_order.present?
          record.update_column(:company_id, record.purchase_order.company_id)
        end
      end

      UserDepartmentMapping.find_each do |record|
        if record.department.present?
          record.update_column(:company_id, record.department.company_id)
        end
      end

      UserDelegateMapping.find_each do |record|
        if record.department.present?
          record.update_column(:company_id, record.department.company_id)
        end
      end

      UserBalanceHistory.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserBranchLocationMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserDropDownItemMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserFieldMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserGroupItemMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserLoginTrack.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserManagerMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserTag.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserWalletTrack.find_each do |record|
        if record.user_wallet.present?
          record.update_column(:company_id, record.user_wallet.company_id)
        end
      end

      UserWalletTrack.find_each do |record|
        if record.user_wallet.present?
          record.user_wallet_track_action.update_column(:company_id, record.user_wallet.company_id)
        end
      end

      Address.find_each do |record|
        if record.parent.present?
          record.update_column(:company_id, record.parent.company_id)
        end
      end

      ApprovalRoute.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      Authentication.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      AutoReloadConfig.find_each do |record|
        if record.reloadable.present?
          record.update_column(:company_id, record.reloadable.company_id)
        end
      end

      BalanceSheet.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      BankAccount.where.not(bank_account_master_id: nil).find_each do |record|
        if record.company.present?
          record.bank_account_master.update_column(:company_id, record.company.company_id)
        end
      end

      BankPaymentRequestComment.find_each do |record|
        if record.bank_payment_request.present?
          record.update_column(:company_id, record.bank_payment_request.company_id)
        end
      end

      BankPaymentRequestTrail.find_each do |record|
        if record.bank_payment_request.present?
          record.update_column(:company_id, record.bank_payment_request.company_id)
        end
      end

      BbpsSubscriptionField.find_each do |record|
        if record.subscription.present?
          record.update_column(:company_id, record.subscription.company_id)
        end
      end

      BbpsSubscriptionPoc.find_each do |record|
        if record.subscription.present?
          record.update_column(:company_id, record.subscription.company_id)
        elsif record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      BookingRequest.find_each do |record|
        if record.travel_request_destination.present?
          record.update_column(:company_id, record.travel_request_destination.company_id)
        end
      end

      BookingRestaurant.find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BudgetCriteriaMapping.find_each do |record|
        if record.budget.present?
          record.update_column(:company_id, record.budget.company_id)
        end
      end

      BudgetModificationTrail.find_each do |record|
        if record.budget.present?
          record.update_column(:company_id, record.budget.company_id)
        end
      end

      BudgetRuleBranchLocationMapping.find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      BudgetRuleDepartmentMapping.find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      BudgetRuleExpenseTypeMapping.find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      CardAssignRequestTrack.find_each do |record|
        if record.card_assign_request.present?
          record.update_column(:company_id, record.card_assign_request.company_id)
        end
      end

      CardBalanceHistory.find_each do |record|
        if record.card.present?
          record.update_column(:company_id, record.card.company_id)
        end
      end

      CardConfiguration.find_each do |record|
        if record.prepaid_card.present?
          record.update_column(:company_id, record.prepaid_card.company_id)
        end
      end

      CardExpenseConfig.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      CardRestriction.find_each do |record|
        if record.card.present?
          record.update_column(:company_id, record.card.company_id)
        end
      end

      CardLimit.find_each do |record|
        if record.card_restriction.present?
          record.update_column(:company_id, record.card_restriction.company_id)
        end
      end

      CashExpenseConfig.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      CompanyKycTrail.find_each do |record|
        if record.company_kyc.present?
          record.update_column(:company_id, record.company_kyc.company_id)
        end
      end

      CompanyLocationDepartment.find_each do |record|
        if record.branch_location.present?
          record.update_column(:company_id, record.branch_location.company_id)
        elsif record.company_department.present?
          record.update_column(:company_id, record.company_department.company_id)
        end
      end

      Contact.find_each do |record|
        if record.contactable.present?
          record.update_column(:company_id, record.contactable.company_id)
        end
      end

      CreditNoteAdjustment.find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        elsif record.credit_note.present?
          record.update_column(:company_id, record.credit_note.company_id)
        end
      end

      CreditNoteItem.find_each do |record|
        if record.parent.present?
          record.update_column(:company_id, record.parent.company_id)
        end
      end

      CustomExportConfiguration.find_each do |record|
        if record.configurable.present?
          if record.configurable_type == 'Company'
            record.update_column(:company_id, record.configurable_type_id)
          else
            record.update_column(:company_id, record.configurable.company_id)
          end
        end
      end

      CustomerAttachment.find_each do |record|
        if record.customer.present?
          record.update_column(:company_id, record.customer.company_id)
        end
      end

      CustomerAccount.find_each do |record|
        if record.customer.present?
          record.update_column(:company_id, record.customer.company_id)
        end
      end

      CustomerAccountTransaction.find_each do |record|
        if record.customer_account.present?
          record.update_column(:company_id, record.customer_account.company_id)
        end
      end

      DocumentSlice.find_each do |record|
        if record.receipt.present?
          record.update_column(:company_id, record.receipt.company_id)
        end
      end

      DocumentMessage.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      DocumentMessageReceipt.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      DocumentItem.find_each do |record|
        if record.inventory_line_item.present?
          record.update_column(:company_id, record.inventory_line_item.company_id)
        elsif record.parent_document.present?
          record.update_column(:company_id, record.parent_document.company_id)
        end
      end

      EmailAuthorization.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      Email.find_each do |record|
        record.events.each do |event|
          event.update_column(:company_id, record.company_id)
        end
      end

      ReceiptEmail.find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      ExpenseDataExtract.find_each do |record|
        if record.extractable.present?
          record.update_column(:company_id, record.extractable.company_id)
        end
      end

      ExpenseRule.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      FeatureSubscription.find_each do |record|
        if record.subscribable.present?
          record.update_column(:company_id, record.subscribable_id)
        end
      end

      Feedback.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      FieldAmount.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldBoolean.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDateTime.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDate.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDecimal.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDropDownItem.find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      FieldMultiselectItem.find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      FieldMultiselectSelection.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldMultiselectSelectionItem.find_each do |record|
        if record.field_multiselect_selection.present?
          record.update_column(:company_id, record.field_multiselect_selection.company_id)
        end
      end

      FieldNumber.find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FormCustomField.find_each do |record|
        if record.form.present?
          record.update_column(:company_id, record.form.company_id)
        end
      end

      GstinLocation.find_each do |record|
        if record.gstin_master.present?
          record.gstin_master.update_column(:company_id, record.company_id)
        end
      end

      IndividualKycTrack.find_each do |record|
        if record.individual_kyc.present?
          record.update_column(:company_id, record.individual_kyc.company_id)
        end
      end

      InvoiceTransactionMapping.find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        end
      end

      InwardDocumentItem.find_each do |record|
        if record.inward_document.present?
          record.update_column(:company_id, record.inward_document.company_id)
        end
      end

      ItzCashDmtSender.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ItzCashDmtBeneficiary.find_each do |record|
        if record.itz_cash_dmt_sender.present?
          record.update_column(:company_id, record.itz_cash_dmt_sender.company_id)
        end
      end

      LevelReviewerMapping.find_each do |record|
        if record.reviewer.present?
          record.update_column(:company_id, record.reviewer.company_id)
        end
      end

      LevelUserReviewerMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      LoginAgreementMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ManagerSummaryMailConfig.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      MapLocationUserQuery.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      MccCategoryMapping.find_each do |record|
        if record.category.present?
          record.update_column(:company_id, record.category.company_id)
        end
      end

      MoneyRequestProcessorMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      MoneyRequestTrack.find_each do |record|
        if record.money_request.present?
          record.update_column(:company_id, record.money_request.company_id)
        end
      end

      Notification.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      NotifierTypeConfiguration.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      OutwardInvoiceTrail.find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        end
      end

      PaymentAgreementEscalation.find_each do |record|
        if record.payment_agreement.present?
          record.update_column(:company_id, record.payment_agreement.company_id)
        end
      end

      PaymentOrderAttachment.find_each do |record|
        if record.payment_order.present?
          record.update_column(:company_id, record.payment_order.company_id)
        end
      end

      PolicyConfiguration.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      PolicyUserMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PostOperationAction.find_each do |record|
        if record.post_operatable.present?
          record.update_column(:company_id, record.post_operatable.company_id)
        end
      end

      ReceiptEmailAttachment.find_each do |record|
        if record.receipt_email.present?
          record.update_column(:company_id, record.receipt_email.company_id)
        end
      end

      ReportProcessorGroupMapping.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ReportTrack.find_each do |record|
        if record.report.present?
          record.update_column(:company_id, record.report.company_id)
        end
      end

      ResourceTemplate.find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ReviewalLevel.find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      TranscribedExpense.find_each do |record|
        if record.receipt.present?
          record.update_column(:company_id, record.receipt.company_id)
        end
      end

      TravelRequestComment.find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      TravelRequestTrail.find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      TripRoute.find_each do |record|
        if record.trip.present?
          record.update_column(:company_id, record.trip.company_id)
        end
      end

      TripPassenger.find_each do |record|
        if record.trip.present?
          record.update_column(:company_id, record.trip.company_id)
        end
      end

      UserSessionEvent.find_each do |record|
        if record.user_session.present?
          record.update_column(:company_id, record.user_session.company_id)
        end
      end
    end
  end
end

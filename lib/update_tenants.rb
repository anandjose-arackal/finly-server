class UpdateTenants
  # TODO: need to update script to fetch in batches and do bulk updates
  def self.run
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    ActsAsTenant.without_tenant do
      UserPanelSubscription.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserRoleMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserProfile.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PolicyUserRole.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserWallet.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      VendorPaymentWallet.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserPocket.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PolicyDepartmentMapping.includes(:policy).find_each do |record|
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

      PolicyLocationMapping.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      DocumentLevelReviewerMapping.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      ProcurementStatusTaggable.includes(:procurement).find_each do |record|
        if record.procurement.present?
          record.update_column(:company_id, record.procurement.company_id)
        end
      end

      FieldParentMapping.includes(:field_configuration).find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      PurchaseRequestItem.includes(:purchase_request).find_each do |record|
        if record.purchase_request.present?
          record.update_column(:company_id, record.purchase_request.company_id)
        end
      end

      CashOnHand.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      GstinLocation.includes(:vendor).find_each do |record|
        if record.vendor.present?
          record.update_column(:company_id, record.vendor.company_id)
        end
      end

      UserGroupItem.includes(:user_group).find_each do |record|
        if record.user_group.present?
          record.update_column(:company_id, record.user_group.company_id)
        end
      end

      UserTeamGroupItemMapping.includes(:user_group).find_each do |record|
        if record.user_group.present?
          record.update_column(:company_id, record.user_group.company_id)
        end
      end

      UserIp.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserAgentClient.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      BudgetGroupCriteriaMapping.includes(:budget_group_criterium).find_each do |record|
        if record.budget_group_criterium.present?
          record.update_column(:company_id, record.budget_group_criterium.company_id)
        end
      end

      BudgetConsumption.includes(:budget).find_each do |record|
        if record.budget.present?
          record.update_column(:company_id, record.budget.company_id)
        end
      end

      CustomField.includes(:field_configuration).find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      BudgetTrail.includes(:entity).find_each do |record|
        if record.entity.present?
          record.update_column(:company_id, record.entity.company_id)
        end
      end

      Expense.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PurchaseOrderItem.includes(:purchase_order).find_each do |record|
        if record.purchase_order.present?
          record.update_column(:company_id, record.purchase_order.company_id)
        end
      end

      InvoiceLineItem.includes(:invoice).find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        end
      end

      Booking.includes(:travel_request).find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      MoneyRequest.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      Receipt.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      TravelRequestDestination.includes(:travel_request).find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      PolicyFieldMapping.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      Trail.includes(:action_user).find_each do |record|
        if record.action_user.present?
          record.update_column(:company_id, record.action_user.company_id)
        end
      end

      FieldDropDownSelection.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      BudgetRule.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      BudgetRuleCategoryMapping.includes(:budget_rule).find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      BudgetRuleFieldMapping.includes(:budget_rule).find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      ReportComment.includes(:report).find_each do |record|
        if record.report.present?
          record.update_column(:company_id, record.report.company_id)
        end
      end

      MoneyRequestItem.includes(:money_request).find_each do |record|
        if record.money_request.present?
          record.update_column(:company_id, record.money_request.company_id)
        end
      end

      MoneyRequestComment.includes(:money_request).find_each do |record|
        if record.money_request.present?
          record.update_column(:company_id, record.money_request.company_id)
        end
      end

      DistanceExpenseConfig.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      TimeExpenseConfig.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      VehicleRate.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      PerDiemExpenseConfig.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      PerDiem.includes(:configurable).find_each do |record|
        if record.configurable.present?
          record.update_column(:company_id, record.configurable.company_id)
        end
      end

      ParentDependentFieldConfigurationMapping.includes(:dependent_field_configuration).find_each do |record|
        if record.dependent_field_configuration.present?
          record.update_column(:company_id, record.dependent_field_configuration.company_id)
        end
      end

      SystemMessage.includes(:messagable).find_each do |record|
        if record.messagable.present?
          record.update_column(:company_id, record.messagable.company_id)
        end
      end

      DuplicateExpenseMapping.includes(:expense).find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      ManualExpense.includes(:expense).find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      CardExpense.includes(:expense).find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      DistanceExpense.includes(:expense).find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      TimeExpense.includes(:expense).find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      PerDiemExpense.includes(:expense).find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      BookingFlight.includes(:booking).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingTrain.includes(:booking).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingBus.includes(:booking).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingCarRental.includes(:booking).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingHotel.includes(:booking).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BookingOther.includes(:booking).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      RateContractLineItem.includes(:rate_contract).find_each do |record|
        if record.rate_contract.present?
          record.update_column(:company_id, record.rate_contract.company_id)
        end
      end

      FieldText.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      CardTransaction.includes(:card).find_each do |record|
        if record.card.present?
          record.update_column(:company_id, record.card.company_id)
        end
      end

      AutoSubmitConfig.includes(:submitable).find_each do |record|
        if record.submitable.present?
          record.update_column(:company_id, record.submitable.company_id)
        end
      end

      KycDocument.includes(:company_kyc).find_each do |record|
        if record.company_kyc.present?
          record.update_column(:company_id, record.company_kyc.company_id)
        end
      end

      FieldCustomization.includes(:scopable).find_each do |record|
        if record.scopable.present?
          record.update_column(:company_id, record.scopable.id)
        end
      end

      ProcurementComment.includes(:parent_commentable).find_each do |record|
        if record.parent_commentable.present?
          record.update_column(:company_id, record.parent_commentable.company_id)
        end
      end

      Quotation.includes(:purchase_order).find_each do |record|
        if record.purchase_order.present?
          record.update_column(:company_id, record.purchase_order.company_id)
        end
      end

      UserDepartmentMapping.includes(:department).find_each do |record|
        if record.department.present?
          record.update_column(:company_id, record.department.company_id)
        end
      end

      UserDelegateMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserBalanceHistory.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserBranchLocationMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserDropDownItemMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserFieldMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserGroupItemMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserLoginTrack.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserManagerMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserTag.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      UserWalletTrack.includes(:user_wallet).find_each do |record|
        if record.user_wallet.present?
          record.update_column(:company_id, record.user_wallet.company_id)
        end
      end

      UserWalletTrack.includes(:record).find_each do |record|
        if record.user_wallet.present?
          record.user_wallet_track_action.update_column(:company_id, record.user_wallet.company_id)
        end
      end

      Address.includes(:parent).find_each do |record|
        if record.parent.present?
          record.update_column(:company_id, record.parent.company_id)
        end
      end

      ApprovalRoute.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      Authentication.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      AutoReloadConfig.includes(:reloadable).find_each do |record|
        if record.reloadable.present?
          record.update_column(:company_id, record.reloadable.company_id)
        end
      end

      BalanceSheet.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      BankAccount.where.not(bank_account_master_id: nil).includes(:company).find_each do |record|
        if record.company.present?
          record.bank_account_master.update_column(:company_id, record.company.company_id)
        end
      end

      BankPaymentRequestComment.includes(:bank_payment_request).find_each do |record|
        if record.bank_payment_request.present?
          record.update_column(:company_id, record.bank_payment_request.company_id)
        end
      end

      BankPaymentRequestTrail.includes(:bank_payment_request).find_each do |record|
        if record.bank_payment_request.present?
          record.update_column(:company_id, record.bank_payment_request.company_id)
        end
      end

      BbpsSubscriptionField.includes(:subscription).find_each do |record|
        if record.subscription.present?
          record.update_column(:company_id, record.subscription.company_id)
        end
      end

      BbpsSubscriptionPoc.includes([:subscription, :user]).find_each do |record|
        if record.subscription.present?
          record.update_column(:company_id, record.subscription.company_id)
        elsif record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      BookingRequest.includes(:travel_request_destination).find_each do |record|
        if record.travel_request_destination.present?
          record.update_column(:company_id, record.travel_request_destination.company_id)
        end
      end

      BookingRestaurant.includes(:booking).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        end
      end

      BudgetCriteriaMapping.includes(:budget).find_each do |record|
        if record.budget.present?
          record.update_column(:company_id, record.budget.company_id)
        end
      end

      BudgetModificationTrail.includes(:budget).find_each do |record|
        if record.budget.present?
          record.update_column(:company_id, record.budget.company_id)
        end
      end

      BudgetRuleBranchLocationMapping.includes(:budget_rule).find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      BudgetRuleDepartmentMapping.includes(:budget_rule).find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      BudgetRuleExpenseTypeMapping.includes(:budget_rule).find_each do |record|
        if record.budget_rule.present?
          record.update_column(:company_id, record.budget_rule.company_id)
        end
      end

      CardAssignRequestTrack.includes(:card_assign_request).find_each do |record|
        if record.card_assign_request.present?
          record.update_column(:company_id, record.card_assign_request.company_id)
        end
      end

      CardBalanceHistory.includes(:card).find_each do |record|
        if record.card.present?
          record.update_column(:company_id, record.card.company_id)
        end
      end

      CardConfiguration.includes(:prepaid_card).find_each do |record|
        if record.prepaid_card.present?
          record.update_column(:company_id, record.prepaid_card.company_id)
        end
      end

      CardExpenseConfig.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      CardRestriction.includes(:card).find_each do |record|
        if record.card.present?
          record.update_column(:company_id, record.card.company_id)
        end
      end

      CardLimit.includes(:card_restriction).find_each do |record|
        if record.card_restriction.present?
          record.update_column(:company_id, record.card_restriction.company_id)
        end
      end

      CashExpenseConfig.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      CompanyKycTrail.includes(:company_kyc).find_each do |record|
        if record.company_kyc.present?
          record.update_column(:company_id, record.company_kyc.company_id)
        end
      end

      CompanyLocationDepartment.includes([:branch_location, :company_department]).find_each do |record|
        if record.branch_location.present?
          record.update_column(:company_id, record.branch_location.company_id)
        elsif record.company_department.present?
          record.update_column(:company_id, record.company_department.company_id)
        end
      end

      Contact.includes(:contactable).find_each do |record|
        if record.contactable.present?
          record.update_column(:company_id, record.contactable.company_id)
        end
      end

      CreditNoteAdjustment.includes(:invoice).find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        elsif record.credit_note.present?
          record.update_column(:company_id, record.credit_note.company_id)
        end
      end

      CreditNoteItem.includes(:parent).find_each do |record|
        if record.parent.present?
          record.update_column(:company_id, record.parent.company_id)
        end
      end

      CustomExportConfiguration.find_each do |record|
        if record.configurable.present?
          if record.configurable_type == 'Company'
            record.update_column(:company_id, record.configurable_id)
          else
            record.update_column(:company_id, record.configurable.company_id)
          end
        end
      end

      CustomerAttachment.includes(:customer).find_each do |record|
        if record.customer.present?
          record.update_column(:company_id, record.customer.company_id)
        end
      end

      CustomerAccount.includes(:customer).find_each do |record|
        if record.customer.present?
          record.update_column(:company_id, record.customer.company_id)
        end
      end

      CustomerAccountTransaction.includes(:customer_account).find_each do |record|
        if record.customer_account.present?
          record.update_column(:company_id, record.customer_account.company_id)
        end
      end

      DocumentSlice.includes(:receipt).find_each do |record|
        if record.receipt.present?
          record.update_column(:company_id, record.receipt.company_id)
        end
      end

      DocumentMessage.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      DocumentMessageReceipt.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      DocumentItem.includes(:inventory_line_item).find_each do |record|
        if record.inventory_line_item.present?
          record.update_column(:company_id, record.inventory_line_item.company_id)
        elsif record.parent_document.present?
          record.update_column(:company_id, record.parent_document.company_id)
        end
      end

      EmailAuthorization.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ReceiptEmail.includes(:expense).find_each do |record|
        if record.expense.present?
          record.update_column(:company_id, record.expense.company_id)
        end
      end

      ExpenseDataExtract.includes(:extractable).find_each do |record|
        if record.extractable.present?
          record.update_column(:company_id, record.extractable.company_id)
        end
      end

      ExpenseRule.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      FeatureSubscription.find_each do |record|
        if record.subscribable.present?
          record.update_column(:company_id, record.subscribable_id)
        end
      end

      Feedback.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      FieldAmount.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldBoolean.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDateTime.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDate.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDecimal.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldDropDownItem.includes(:field_configuration).find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      FieldMultiselectItem.includes(:field_configuration).find_each do |record|
        if record.field_configuration.present?
          record.update_column(:company_id, record.field_configuration.company_id)
        end
      end

      FieldMultiselectSelection.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FieldMultiselectSelectionItem.includes(:field_multiselect_selection).find_each do |record|
        if record.field_multiselect_selection.present?
          record.update_column(:company_id, record.field_multiselect_selection.company_id)
        end
      end

      FieldNumber.includes(:custom_field).find_each do |record|
        if record.custom_field.present?
          record.update_column(:company_id, record.custom_field.company_id)
        end
      end

      FormCustomField.includes(:form).find_each do |record|
        if record.form.present?
          record.update_column(:company_id, record.form.company_id)
        end
      end

      GstinLocation.find_each do |record|
        if record.gstin_master.present?
          record.gstin_master.update_column(:company_id, record.company_id)
        end
      end

      IndividualKycTrack.includes(:individual_kyc).find_each do |record|
        if record.individual_kyc.present?
          record.update_column(:company_id, record.individual_kyc.company_id)
        end
      end

      InvoiceTransactionMapping.includes(:invoice).find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        end
      end

      InwardDocumentItem.includes(:inward_document).find_each do |record|
        if record.inward_document.present?
          record.update_column(:company_id, record.inward_document.company_id)
        end
      end

      ItzCashDmtSender.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ItzCashDmtBeneficiary.includes(:itz_cash_dmt_sender).find_each do |record|
        if record.itz_cash_dmt_sender.present?
          record.update_column(:company_id, record.itz_cash_dmt_sender.company_id)
        end
      end

      LevelReviewerMapping.includes(:reviewer).find_each do |record|
        if record.reviewer.present?
          record.update_column(:company_id, record.reviewer.company_id)
        end
      end

      LevelUserReviewerMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      LoginAgreementMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ManagerSummaryMailConfig.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      MapLocationUserQuery.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      MccCategoryMapping.includes(:category).find_each do |record|
        if record.category.present?
          record.update_column(:company_id, record.category.company_id)
        end
      end

      MoneyRequestProcessorMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      MoneyRequestTrack.includes(:money_request).find_each do |record|
        if record.money_request.present?
          record.update_column(:company_id, record.money_request.company_id)
        end
      end

      Notification.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      NotifierTypeConfiguration.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      OutwardInvoiceTrail.includes(:invoice).find_each do |record|
        if record.invoice.present?
          record.update_column(:company_id, record.invoice.company_id)
        end
      end

      PaymentAgreementEscalation.includes(:payment_agreement).find_each do |record|
        if record.payment_agreement.present?
          record.update_column(:company_id, record.payment_agreement.company_id)
        end
      end

      PaymentOrderAttachment.includes(:payment_order).find_each do |record|
        if record.payment_order.present?
          record.update_column(:company_id, record.payment_order.company_id)
        end
      end

      PolicyConfiguration.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      PolicyUserMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      PostOperationAction.includes(:post_operatable).find_each do |record|
        if record.post_operatable.present?
          record.update_column(:company_id, record.post_operatable.company_id)
        end
      end

      ReceiptEmailAttachment.includes(:receipt_email).find_each do |record|
        if record.receipt_email.present?
          record.update_column(:company_id, record.receipt_email.company_id)
        end
      end

      ReportProcessorGroupMapping.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ReportTrack.includes(:report).find_each do |record|
        if record.report.present?
          record.update_column(:company_id, record.report.company_id)
        end
      end

      ResourceTemplate.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      ReviewalLevel.includes(:policy).find_each do |record|
        if record.policy.present?
          record.update_column(:company_id, record.policy.company_id)
        end
      end

      TranscribedExpense.includes(:receipt).find_each do |record|
        if record.receipt.present?
          record.update_column(:company_id, record.receipt.company_id)
        end
      end

      TravelRequestComment.includes(:travel_request).find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      TravelRequestTrail.includes(:travel_request).find_each do |record|
        if record.travel_request.present?
          record.update_column(:company_id, record.travel_request.company_id)
        end
      end

      TripRoute.includes(:trip).find_each do |record|
        if record.trip.present?
          record.update_column(:company_id, record.trip.company_id)
        end
      end

      TripPassenger.includes(:trip).find_each do |record|
        if record.trip.present?
          record.update_column(:company_id, record.trip.company_id)
        end
      end

      UserSessionEvent.includes(:user_session).find_each do |record|
        if record.user_session.present?
          record.update_column(:company_id, record.user_session.company_id)
        end
      end

      AdminSummaryMailConfig.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

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

      GeneralInvoice.where.not(invoice_frequency_id: nil).find_each do |record|
        record.invoice_frequency.update_column(:company_id, record.company_id)
      end

      RentalInvoice.where.not(invoice_frequency_id: nil).find_each do |record|
        record.invoice_frequency.update_column(:company_id, record.company_id)
      end

      PaymentTrail.includes(:macro).find_each do |record|
        if record.initiating_account.present? && record.initiating_account.respond_to?(:company)
          record.update_column(:company_id, record.initiating_account.company_id)
        elsif record.initiating_user.present? && record.initiating_user.respond_to?(:company)
          record.update_column(:company_id, record.initiating_user.company_id)
        end
      end

      ProcurementCharge.find_each do |record|
        if record.chargable.present?
          record.update_column(:company_id, record.chargable.company_id)
        end
      end

      ReceiptEmailParseFailure.includes(:user).find_each do |record|
        if record.user.present?
          record.update_column(:company_id, record.user.company_id)
        end
      end

      VirtualAccountTransaction.includes(:virtual_account).find_each do |record|
        if record.virtual_account.present?
          record.update_column(:company_id, record.virtual_account.company_id)
        end
      end

      SystemLog.includes(:log_resource).find_each do |record|
        if record.log_resource.present?
          record.update_column(:company_id, record.log_resource.company_id)
        end
      end

      TaskWorkflow.where.not(task_schedule_id: nil).find_each do |record|
        record.task_schedule.update_column(:company_id, record.company_id)
      end

      TaskWorkflow.find_each do |tw|
        tw.file_manager_actions.each do |record|
          record.update_column(:company_id, tw.company_id)
        end
      end

      TaxPerItem.includes(:tax_rate).find_each do |record|
        if record.tax_rate.present?
          record.update_column(:company_id, record.tax_rate.company_id)
        end
      end

      TimeExpense.where.not(time_object_id: nil).find_each do |te|
        te.time_object.update_column(:company_id, te.company_id)
      end

      TravelMember.includes([:booking, :booking_request]).find_each do |record|
        if record.booking.present?
          record.update_column(:company_id, record.booking.company_id)
        elsif record.booking_request.present?
          record.update_column(:company_id, record.booking_request.company_id)
        end
      end

      VendorAccount.includes(:vendor).find_each do |record|
        if record.vendor.present?
          record.update_column(:company_id, record.vendor.company_id)
        end
      end

      VendorAccountTransaction.includes(:vendor_account).find_each do |record|
        if record.vendor_account.present?
          record.update_column(:company_id, record.vendor_account.company_id)
        end
      end

      VendorAttachment.includes(:yes_bank_vendor).find_each do |record|
        if record.yes_bank_vendor.present?
          record.update_column(:company_id, record.yes_bank_vendor.company_id)
        end
      end

      VendorTdsRate.includes(:vendor).find_each do |record|
        if record.vendor.present?
          record.update_column(:company_id, record.vendor.company_id)
        end
      end

      WebHookEventMapping.includes(:web_hook).find_each do |record|
        if record.web_hook.present?
          record.update_column(:company_id, record.web_hook.company_id)
        end
      end
    end
  end
end

user = @result.selected_user
json.partial! 'user', user: user

policy_ids = user.policy_user_roles.pluck(:policy_id).uniq
policy_ids += user.policy_user_mapping.pluck(:policy_id).uniq
policies = Policy.with_id(policy_ids)
# adding approval flow here for this particular user
json.approval_flow do
  provider_names = %w( PurchaseOrderProvider PoInvoiceProvider NonPoInvoiceProvider AgreementInvoiceProvider ReportProvider MoneyRequestProvider BankPaymentRequestProvider TravelRequestProvider TravelRequestBookingProvider YesBankVendorProvider PurchaseRequestProvider PaymentAgreementProvider BbpsBillerSubscriptionProvider BbpsBillProvider CreditNoteProvider )
  policies.each do |policy|
    json.policy_id policy.id
    json.policy_name policy.name
    provider_names.each do |provider|
      params[:provider_name] = provider
      op = ReviewalManager::ReviewalChain.(user, {policy_id: policy.id, provider_name: provider})
      op.chain.each do |approval_chain|
        json.level_number approval_chain[:level_number]
        json.level_name approval_chain[:level_name]
        json.reviewers do
          json.array!(approval_chain.reviewer_data) do |data|
            json.reviewer_id data[:reviewer_id]
            json.reviewer_name data[:reviewer_name]
            json.threshold data[:threshold]
            json.exception data[:exception]
            json.min data[:min]
            json.max data[:max]
          end
        end
      end
    end
  end
end

# adding the policy user roles here also
json.user_roles do
  policies.each do |policy|
    json.policy_id policy.id
    json.policy_name policy.name
    json.roles_within_policy do
      policy.policy_user_roles.with_user_id(user.id).each do |pur|
        json.role_name pur.user_role&.name&.humanize
      end
    end
  end
end
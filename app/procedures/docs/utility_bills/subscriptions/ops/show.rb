class Docs::UtilityBills::Subscriptions::Ops::Show < Transactions::API
  step Model(BbpsBillerSubscription, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Subscriptions::Authorizer, :show?)
  step :additional_data
  # step Transactions::Resolver::Model(BbpsBillerSubscription)


  def additional_data(options, model:, **)
    tabs = [{name: 'details', display_name: 'Details'}]
    if BbpsBillerSubscription.status_ids(:approved, :auto_approved, :deactivated, :reactivated).include?(model&.status_id)
      tabs.push({name: 'bills', display_name: 'Bills'})
    end

    options['result'] = {
        'tabs' => tabs
    }
  end
end
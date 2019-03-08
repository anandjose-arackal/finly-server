class TravelRequests::Config::Show < BaseOperation
  attr_accessor :policies

  def pre_validate
    user_present?
  end

  def init
    result = Policy::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    if user.enforce_policy_enabled?
      self.policies = result.policies.non_deleted.with_application(current_app).non_default
    else
      self.policies =  result.policies.non_deleted.with_application(current_app)
    end
  end

  def success
    params[:policies] = self.policies
    TravelRequests::Config::Show::Presenter.new(user, params, messages)
  end

  class TravelRequests::Config::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policies

    def init
      self.policies = params[:policies]
    end

    def custom_fields_for(policy)
      return nil unless policy.present?
      policy.field_configurations.exclude_deleted.root_fields
                           .order_created_at_desc.with_parent_type(FieldParentType.id_for(:travel_request))
    end

  end

end
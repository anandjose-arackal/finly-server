class TravelRequests::Create < TravelRequests::Base
  attr_accessor :travel_request_parameters, :travel_request, :for_user

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:travel_request, :create], :post_validate, self)
        }
    }
  end

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.for_user = (params[:for_user] or user)

    self.travel_request_parameters = strong_params
    self.travel_request_parameters[:status_id] = TravelRequestStatus.id_for(:open)
    self.travel_request_parameters[:controlling_user] = user
    self.travel_request_parameters[:controlling_user_role_id] = UserRole.id_for(:employee)
    self.travel_request_parameters[:company_id] = user.company_id
    #self.travel_request_parameters[:policy_id] = current_company.policies.default.first.id

    if self.travel_request_parameters[:policy_id].blank? and for_user.enforce_policy_enabled?
      self.travel_request_parameters[:policy_id] = for_user.policies.non_default&.first&.id
    end
    if self.travel_request_parameters[:policy_id].blank?
      self.travel_request_parameters[:policy_id] = user.company.default_policy.id
    end
    self.travel_request = self.for_user.travel_requests.build(travel_request_parameters)
  end

  def validate
    unless self.travel_request.valid?
      add_message :error, self.travel_request.errors.full_messages
    end
  end

  def process
    travel_request.save
  end

  def post_process
    add_message :success, 'New trip created'
  end

  def success
    params[:travel_request_id] = self.travel_request.id
    TravelRequests::Create::CreatePresenter.new(user, params, messages)
  end

  protected
  def strong_params
    params.permit(:name, :policy_id, :purpose_of_travel, :memo, :from_date, :to_date)
  end

  class TravelRequests::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :id

    def init
      self.id = params[:travel_request_id]
    end
  end

end

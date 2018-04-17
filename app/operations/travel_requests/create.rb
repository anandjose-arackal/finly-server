class TravelRequests::Create < TravelRequests::Base
  attr_accessor :travel_request_parameters, :travel_request

  def pre_validate
  end

  def init
    self.travel_request_parameters = {}


    self.travel_request_parameters[:status_id] = TravelRequestStatus.id_for(:open)
    self.travel_request_parameters[:controlling_user] = user
    self.travel_request_parameters[:controlling_user_role_id] = UserRole.id_for(:employee)
    self.travel_request_parameters[:policy_id] = current_company.policies.default.first.id
  end

  def validate
    # check if policy belongs to company
  end

  def process
    self.travel_request = user.travel_requests.build(travel_request_parameters)
    self.travel_request.company_id = user.company.id
    if travel_request.save
      add_message :success, 'Successfully saved travel request'
    else
      add_message :error, self.travel_request.errors.full_messages
    end
  end

  def success
    params[:travel_request_id] = self.travel_request.id
    TravelRequests::Create::CreatePresenter.new(user, params, messages)
  end

  class TravelRequests::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :id

    def init
      self.id = params[:travel_request_id]
    end
  end
end

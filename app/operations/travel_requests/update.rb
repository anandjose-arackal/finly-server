class TravelRequests::Update < TravelRequests::Base
  attr_accessor :travel_request, :travel_request_parameters,
                :associated_report, :associated_money_request,
                :new_associated_report_id, :new_associated_money_request_id

  def init
    self.travel_request = TravelRequest.find(params[:id] || params[:travel_request_id])
    self.travel_request_parameters = travel_request_params
  end

  def validate

  end

  def pre_process
    self.associated_report = self.travel_request.report
    self.associated_money_request = self.travel_request.report&.money_request
    self.new_associated_report_id = travel_request_parameters[:report_id].to_i
    self.new_associated_money_request_id = travel_request_parameters[:money_request_id].to_i
    travel_request_parameters.delete(:report_id)
    travel_request_parameters.delete(:money_request_id)
  end

  def authorize
    policy_id = travel_request_params[:policy_id]
    if policy_id.present? and user.policies.with_id(policy_id).blank?
      add_message :error, 'User does not belong to the selected policy'
      return
    end
  end

  def process
    self.travel_request.assign_attributes(travel_request_parameters)
    if travel_request.valid?
      travel_request.save
      report = user.reports.find_by(id: self.new_associated_report_id)
      if report.present?
        if self.associated_report&.id != self.new_associated_report_id
          report&.update(travel_request_id: self.travel_request.id)
          self.associated_report.update(travel_request_id: nil)
        end
        if self.associated_money_request&.id != self.new_associated_money_request_id
          money_request = user.money_requests.find_by(id: self.new_associated_money_request_id)
          report&.update(money_request_id: money_request.id)
          self.associated_report.update(money_request_id: nil)
        end
      end
      # updating the associated money request and report for the old
      add_message :success, 'Successfully updated travel request'
    else
      add_message :error, self.travel_request.errors.full_messages
    end
  end
end
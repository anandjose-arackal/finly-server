class TravelRequests::Update < TravelRequests::Base
  attr_accessor :travel_request, :travel_request_parameters

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:travel_request, :update], :post_validate, self)
        }
    }
  end

  def pre_validate
    user_present? and params_present?
    validate_delegator_action if actual_current_user.present?
  end

  def init
    show_presenter = TravelRequests::Show.(user, params)
    unless show_presenter.success?
      add_message :error, show_presenter.messages[:error]
      return
    end
    self.travel_request = show_presenter.travel_request
    self.travel_request_parameters = strong_params
  end

  def authorize
    policy_id = travel_request_params[:policy_id]
    if policy_id.present? and user.policies.with_id(policy_id).blank?
      add_message :error, 'User does not belong to the selected policy'
      return
    end
  end

  def validate
    unless self.travel_request.present?
      add_message :error, 'Travel request not found'
      return
    end
    if travel_request_params[:policy_id].present? and
        travel_request_params[:policy_id]&.to_i != travel_request.policy_id and
        (not TravelRequestStatus.ids_for(:open, :retracted, :rejected).include?(travel_request.status_id) or
            travel_request.controlling_user_id != user.id)
      add_message :error, 'Travel request policy cannot be updated at the moment'
      return
    end
  end

  def pre_process
    travel_request_parameters[:modified_by_id] = actual_current_user.id if actual_current_user.present?
  end

  def process
    self.travel_request.assign_attributes(travel_request_parameters)

    # Set custom fields
    custom_fields = {custom_fields: params[:custom_fields]}
    custom_fields[:save] = false
    # custom_fields[:reset_fields] = true
    set_fields = CustomField::SetFields.(self.travel_request, FieldParentType.id_for(:travel_request), custom_fields)
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    # validating the custom fields here
    valid = CustomField::Validate.(self.travel_request)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return false
    end

    if travel_request.save
      # Update money_request DLRMs only when the owner does it
      if travel_request.user_id == user.id && params[:view] == 'personal'

        # Create Document Level Reviewer Mapping
        # For setting level specific reviewers from reviewal chain for a document
        params[:reviewal_document] = self.travel_request.reload
        params[:provider_name] = 'TravelRequestProvider'

        document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
        unless document_reviewer_mappings_op.success?
          add_message :error, document_reviewer_mappings_op.messages[:error]
          return
        end

        # Create Document Level Reviewer Mapping for Travel Request Booking Provider
        params[:provider_name] = 'TravelRequestBookingProvider'
        params[:document_reviewer_mappings] = params[:document_reviewer_mappings_booking]

        document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
        unless document_reviewer_mappings_op.success?
          add_message :error, document_reviewer_mappings_op.messages[:error]
          return
        end

        # Update money requests with new policy id & new approval flow
        policy_id = travel_request.policy_id
        travel_request.money_requests.each do |money_request|
          # Manually update money request > MoneyRequest::Update will not work as MoneyRequest::Index won't return these money requests
          money_request.update(policy_id: policy_id)
          parameters = {
            reviewal_document: money_request,
            provider_name: 'TravelRequestProvider'
          }

          money_request_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, parameters)
        end

      end
    else
      add_message :error, self.travel_request.errors.full_messages
    end
  end

  def post_process
    delegated_action_user_id = actual_current_user.present? ? actual_current_user.id : nil
    travel_request.comments.create(user_id: user.id,
                                   action_id: TravelRequestCommentAction.id_for(:updated_by_delegate), delegated_action_user_id: delegated_action_user_id) if actual_current_user.present?
    add_message :success, 'Successfully updated trip'
  end

  protected

  def strong_params
    params.require(:travel_request).permit(:name, :policy_id, :purpose_of_travel, :memo, :from_date, :to_date, :modified_by_id)
  end

end

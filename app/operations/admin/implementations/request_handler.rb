class Admin::Implementations::RequestHandler < Admin::Base

  attr_accessor :master, :request_key, :implementation_request, :processor, :company

  def pre_validate
    user_present? and params_present?
    return if has_errors?
    if params[:request_key].blank?
      add_message :error, 'Request key is blank'
      return
    end
    if params[:company_id].blank?
      add_message :error, 'Company is not set'
      return
    end

  end

  def init
    self.company = Company.find_by id: params[:company_id]
    self.request_key = params[:request_key]
    self.master = init_master
    return if self.master.blank?
    #self.processor = init_processor
  end

  def validate
    if self.master.blank?
      add_message :error, 'Invalid request_key'
      return
    end
  end

  def process
    self.implementation_request = self.user.admin_implementation_requests.new request_key: params[:request_key],
                                                                              company_id: params[:company_id],
                                                                              request_params: params,
                                                                              master: self.master,
                                                                              name: self.master.name,
                                                                              request_file: params[:request_file],
                                                                              status: :pending,
                                                                              started_at: Time.now
    unless self.implementation_request.valid?
      add_message :error, self.implementation_request.errors.full_messages
      return
    end
    if self.implementation_request.save
      params[:implementation_request_id] =implementation_request.id
      data ={admin_user_id: user.id, company_id: params[:company_id], implementation_request_id: implementation_request.id}
      data[:with_id] = params[:with_id] if params[:with_id].present?
      self.master.call_async(user, data)
      #self.master.call(user, data)
    end
  end

  def post_process
    add_message :success, 'Implementation Request on Processing'
  end

  def success
    Admin::Implementations::RequestHandler::RequestHandlerPresenter.new(user, params, messages)
  end

  class Admin::Implementations::RequestHandler::RequestHandlerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    def init
    end
  end

  protected

  def init_master
    Admin::Implementations::Master::BaseMaster.subscribers(self.request_key)&.first
  end

  def init_processor
    return nil if self.master.blank?
    self.master.new(user,params.to_h)
  end

  def implementation_params
    params&.permit(:implementation_request_id, :country)
  end

end
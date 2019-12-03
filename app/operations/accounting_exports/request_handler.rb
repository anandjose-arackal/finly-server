class AccountingExports::RequestHandler < Admin::Base

  attr_accessor :master, :request_key, :processor

  class AccountingExports::RequestHandler::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :records

    def init
      self.records = params[:records]
    end

  end

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
    self.request_key = params[:request_key]
    self.master = init_master
    return if self.master.blank?
  end

  def validate
    if self.master.blank?
      add_message :error, 'Invalid request_key'
      return
    end
  end

  def process
    data = params
    result = self.master.(user, data)
    if result[:success]
      if result[:message].present?
        add_message :success, result[:message]
      end
      params[:records] = result[:records]
    else
      add_message :error, (result[:message] || 'Unknown error')
    end
  end

  def post_process

  end

  def success
    AccountingExports::RequestHandler::SuccessPresenter.new(user, params, messages)
  end


  protected

  def init_master
    AccountingExports::Master::BaseMaster.subscribers(self.request_key)&.first
  end

  def init_processor
    return nil if self.master.blank?
    self.master.new(user,params.to_h)
  end

end
class Admin::Implementations::RequestHandler < Admin::Base

  attr_accessor :master, :request_key, :implementation_request

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
  end

  def validate
    if self.master.blank?
      add_message :error, 'Invalid request_key'
      return
    end
  end

  def process
    params[:request_file] = File.open("/Users/vivekag/Projects/Rails/finly-server/public/system/admin_implementation_requests/result_files/000/000/021/original/export20190808-60493-16bwrpd.xlsx", "r")
    self.implementation_request = self.user.admin_implementation_requests.new request_key: params[:request_key],
                                                                              company_id: params[:company_id],
                                                                              request_params: params,
                                                                              master: self.master,
                                                                              name: self.master.name,
                                                                              request_file: params[:request_file],
                                                                              status: :pending
    unless self.implementation_request.valid?
      add_message :error, self.implementation_request.errors.full_messages
      return
    end
    self.implementation_request.save
  end

  def post_process
    self.master.call(nil, admin_user_id: user.id, implementation_request_id: self.implementation_request.id)
  end

  protected

  def init_master
    Admin::Implementations::Master::BaseMaster.subscribers(self.request_key)&.first
  end

end
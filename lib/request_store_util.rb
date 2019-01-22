class RequestStoreUtil

  def self.set_current_request(request)
    RequestStore.store[:request] = request
  end

  def self.set_request_params(params)
    RequestStore.store[:params] = params
    RequestStore.store[:request_params] = params&.deep_dup
  end

  def self.set_current_user(user)
    RequestStore.store[:current_user] = user
  end

  def self.set_current_company(company)
    RequestStore.store[:current_company] = company
  end

  def self.set_authorized_scopes(scopes)
    RequestStore.store[:authorized_scopes] = scopes
  end

  def self.set_current_app(app)
    RequestStore.store[:current_app] = app
  end

  def self.set_current_device(device)
    RequestStore.store[:current_devise] = device
  end

  def self.to_hash
    {
        current_app: RequestStore.store[:current_app],
        current_device: RequestStore.store[:current_device],
        current_user_id: RequestStore.store[:current_user]&.id,
        current_user_type: RequestStore.store[:current_user]&.class&.name,
        current_company_id: RequestStore.store[:current_company]&.id,
        authorized_scopes: RequestStore.store[:authorized_scopes],
        params: RequestStore.store[:params]
    }
  end

  def self.from_hash(request_store_data)
    return if request_store_data.blank?
    request_store_data = request_store_data&.with_indifferent_access
    RequestStore.store[:current_app] = request_store_data[:current_app]
    RequestStore.store[:current_device] = request_store_data[:current_device]
    RequestStore.store[:authorized_scopes] = request_store_data[:authorized_scopes]
    RequestStore.store[:params] = request_store_data[:params]
    RequestStore.store[:current_company] = Company.with_id(request_store_data[:current_company_id])&.first
    case request_store_data[:current_user_type]
      when User.name
        RequestStore.store[:current_user] = User.with_id(request_store_data[:current_user_id])&.first
      when AdminUser.name
        RequestStore.store[:current_user] = AdminUser.with_id(request_store_data[:current_user_id])&.first
    end
  end

  def self.current_app
    RequestStore.store[:current_app]
  end

  def self.current_device
    RequestStore.store[:current_device]
  end

  def self.current_user
    RequestStore.store[:current_user]
  end

  def self.authorized_scopes
    RequestStore.store[:authorized_scopes]
  end

  def self.current_company
    RequestStore.store[:current_company]
  end

  def self.current_request
    RequestStore.store[:request]
  end

  def self.request_params
    RequestStore.store[:params]
  end

end
# returns the next reviewer for report, card load request and anything
# else that goes through the standard chain of approval
# constructor takes - cardloadrequest, report, or user

class User::Team::Review::NextReviewer < BaseOperation
  attr_accessor :obj, :next_approver, :role_id

  def personalizer
    {
        post_process: {
            before: Personalizer::Process.new([:user, :team, :review, :next_reviewer], :post_process, self)
        }
    }
  end

  def self.call(obj, params = {})
    self.new(obj, params).run
  end

  def initialize(obj, params = {})
    super(nil, params)
    self.obj = obj
  end

  def validate
    messages[:error] << 'Error retrieving next reviewer' if obj.blank?
  end

  def process
    if obj.is_a?(MoneyRequest)
      next_reviewer(:money_request, obj)
    elsif obj.is_a?(Report)
      next_reviewer(:report, obj)
    elsif obj.is_a?(BankPaymentRequest)
      next_reviewer(:payment_request, obj)
    elsif obj.is_a?(TravelRequest)
      next_reviewer(:travel_request, obj)
    elsif obj.is_a?(Hash)
      user = obj[:user]
      if user.blank?
        self.response = nil
        return
      end
      amount = obj[:amount]
      currency_id = obj[:currency_id]
      manager = User::Team::Approver.(user, type: :manager, amount: amount,
          currency_id: currency_id, has_violations: params&.dig(:has_violations))
      if manager.blank?
        self.role_id = UserRole.id_for(:manager)
        self.next_approver = manager
      else
        self.next_approver = User::Team::Approver.(user, type: :finance_manager, amount: amount,
            currency_id: currency_id, has_violations: params&.dig(:has_violations))
        if self.next_approver.present?
          self.role_id = UserRole.id_for(:finance_manager)
        end
      end
    end
  end

  def retrieve
    User::Team::Review::NextReviewer::Presenter.new(self.response, role_id: self.role_id)
  end

  class User::Team::Review::NextReviewer::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user, :role_id

    def init
      self.role_id = params[:role_id] if params.present?
    end

  end

  private

  def next_reviewer(sym, obj)
    user = params[:controlling_user] || (obj.controlling_for_user or obj.controlling_user or obj.user)
    role = params[:controlling_user_role_id] || (obj.controlling_for_user_role_id or obj.controlling_user_role_id)
    role = ::UserRole.id_for(:employee) if role.blank? and obj.controlling_user == obj.user
    arg_hash = {}
    arg_hash[sym] = obj
    arg_hash[:has_violations] = params&.dig(:has_violations)
    if role.blank?
      add_message :error, 'Error loading configuration'
      return
    end
    if obj.user.id == user.id and role == UserRole.id_for(:employee)
      arg_hash[:type] = :manager
      manager = User::Team::Approver.(user, arg_hash)
      if manager.nil?
        # i.e. if the object is a travel request the next approver / action taker is the Travel Manager
        if obj.is_a?(TravelRequest)
          arg_hash[:type] = :travel_manager
          self.response = User::Team::Approver.(user, arg_hash)
          if self.response.present?
            self.role_id = UserRole.id_for(:travel_manager)
          end
          return
          # i.e. if it's not a travel request, the next approver / action taker is the travel manager
        else
          arg_hash[:type] = :finance_manager
          self.response = User::Team::Approver.(user, arg_hash)
          if self.response.present?
            self.role_id = UserRole.id_for(:finance_manager)
          end
          return
        end
      else
        self.response = manager
        if self.response.present?
          self.role_id = UserRole.id_for(:manager)
        end
        return
      end
    end
    arg_hash[:type] = :manager
    if (user.manager? || user.vendor_payments_reviewer?) and role == UserRole.id_for(:manager)
      arg_hash[:type] = :approves_to
      manager = User::Team::Approver.(user, arg_hash)
      if manager.nil?
        if obj.is_a?(TravelRequest)
          arg_hash[:type] = :travel_manager
          self.response = User::Team::Approver.(obj.user, arg_hash)
          if self.response.present?
            self.role_id = UserRole.id_for(:travel_manager)
          end
          return
        else
          arg_hash[:type] = :finance_manager
          self.response = User::Team::Approver.(obj.user, arg_hash)
          if self.response.present?
            self.role_id = UserRole.id_for(:finance_manager)
          end
          return
        end
      else
        self.response = manager
        if self.response.present?
          self.role_id = UserRole.id_for(:manager)
        end
        return
      end
    end
    arg_hash[:type] = :finance_manager
    if (user.finance_manager? || user.vendor_payments_creditor?) and role == UserRole.id_for(:finance_manager)
      arg_hash[:type] = :approves_finance_to
      self.response = User::Team::Approver.(user, arg_hash)
      if self.response.present?
        self.role_id = UserRole.id_for(:finance_manager)
      end
      return
    end
    nil
  end

end
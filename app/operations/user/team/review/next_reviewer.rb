# returns the next reviewer for report, card load request and anything
# else that goes through the standard chain of approval
# constructor takes - cardloadrequest, report, or user

class User::Team::Review::NextReviewer < BaseOperation
  attr_accessor :obj

  def self.call(obj)
    self.new(obj).run
  end

  def initialize(obj)
    super(nil, nil)
    self.obj = obj
  end

  def validate
    messages[:error] << 'Error retrieving next approver' if obj.blank?
  end

  def process
    if obj.is_a?(MoneyRequest)
      self.response = next_reviewer(:money_request, obj)
    elsif obj.is_a?(Report)
      self.response = next_reviewer(:report, obj)
    elsif obj.is_a?(Hash)
      user = obj[:user]
      if user.blank?
        self.response = nil
        return
      end
      amount = obj[:amount]
      currency_id = obj[:currency_id]
      manager = User::Team::Approver.(user, type: :manager, amount: amount, currency_id: currency_id)
      if manager.present?
        self.response = manager
      else
        self.response = User::Team::Approver.(user, type: :finance_manager, amount: amount, currency_id: currency_id)
      end
    end
  end

  def retrieve
    self.response
  end

  private
  def next_reviewer(sym, obj)
    user = obj.controlling_for_user
    user = obj.controlling_user if user.blank?
    user = obj.user if user.blank?
    arg_hash={}
    arg_hash[sym] = obj
    if obj.user.id == user.id
      arg_hash[:type] = :manager
      manager = User::Team::Approver.(user, arg_hash)
      if manager.nil?
        arg_hash[:type] = :finance_manager
        return User::Team::Approver.(user, arg_hash)
      else
        return manager
      end
    end
    arg_hash[:type] = :manager
    if user.manager? and User::Team::IsApprover.(user, arg_hash)
      arg_hash[:type] = :approves_to
      manager = User::Team::Approver.(user, arg_hash)
      if manager.nil?
        arg_hash[:type] = :finance_manager
        return User::Team::Approver.(obj.user, arg_hash)
      else
        return manager
      end
    end
    arg_hash[:type] = :finance_manager
    if user.finance_manager? and User::Team::IsApprover.(user, arg_hash)
      arg_hash[:type] = :approves_finance_to
      return User::Team::Approver.(user, arg_hash)
    end
    nil
  end

end
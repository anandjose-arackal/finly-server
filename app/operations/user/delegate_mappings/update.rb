class User::DelegateMappings::Update < User::Base
  attr_accessor :user_delegate_mappings, :delegate_for_user_ids, :user, :selected_user, :delegation_enabled

  def init
    self.delegate_for_user_ids = params[:delegate_for_user_ids].present? ? params[:delegate_for_user_ids].split(',').map(&:to_i) : []
    self.user = User.find_by_id params[:user_id]
    self.delegation_enabled = StringUtils.to_bool(params[:delegation_enabled])
    self.selected_user = User.find_by_id(params[:user_id])
  end

  def validate
    if self.delegation_enabled && delegate_for_user_ids.blank?
        # Disable delegation if no user is present
        self.selected_user.update(delegation_enabled: self.delegation_enabled)
        add_message :error, "Please add atleast one user for delegation"
        return
    # User cannot be delegated to itself
    elsif self.delegation_enabled && !delegate_for_user_ids.blank? && delegate_for_user_ids.include?(selected_user.id)
      add_message :error, "Please remove delegator from list"
      return
    elsif user_has_delegator
      # Users having delegation already
      # One person will have only one delegator
      delegate_ids = UserDelegateMapping.where(delegate_for_user_id: repeated_delegated_for_users).pluck(:delegate_for_user_id).uniq rescue nil
      names =  User.where(id: delegate_ids).map(&:name).join(',') rescue nil
      if !names.blank?
        add_message :error, "#{names} already has a delegation"
        return
      end
    end
  end

  def process
    unless self.selected_user.update(delegation_enabled: self.delegation_enabled)
      add_message :error, self.selected_user.errors.full_messages
      return
    end
    if !delegate_for_user_ids.blank? && self.delegation_enabled
      current_delegate_for_user_ids = user.user_delegate_mappings.pluck(:delegate_for_user_id)
      present_delegate_user_ids = delegate_for_user_ids & current_delegate_for_user_ids
      new_delegate_for_user_ids = delegate_for_user_ids - user.user_delegate_mappings.pluck(:delegate_for_user_id)
      destroy_delegate_for_user_ids = current_delegate_for_user_ids - present_delegate_user_ids
      unless new_delegate_for_user_ids.blank?
        new_delegate_for_user_ids.uniq.each do |delegated_user_id|
          user.user_delegate_mappings.create(user_id: user.id, delegate_for_user_id: delegated_user_id, expense_create: true, expense_update: true, receipt_create: true, receipt_add_to_expense: true, receipt_update: true, report_create: true, report_submit: true, report_retract: true, report_update: true, money_request_create: true, money_request_update: true, money_request_submit: true, money_request_retract: true, travel_request_create: true, travel_request_update: true, travel_request_submit: true, travel_request_retract: true)
        end
      end
      unless destroy_delegate_for_user_ids.blank?
        destroy_delegate_for_user_ids.uniq.each do |delegated_user_id|
          user.user_delegate_mappings.find_by_delegate_for_user_id(delegated_user_id).destroy
        end
      end
    elsif delegate_for_user_ids.blank? && !self.delegation_enabled
      user.user_delegate_mappings.destroy_all       
    end
  end 

  def post_process
    add_message :success, "Delegation Updated Successfully"
  end

  def user_has_delegator
    repeated_delegated_for_users
    return self.delegation_enabled && !delegate_for_user_ids.blank? && !repeated_delegated_for_users.blank?
  end

  def repeated_delegated_for_users
    delegate_ids = UserDelegateMapping.where.not(user_id: self.selected_user.id).where(delegate_for_user_id: delegate_for_user_ids).pluck(:delegate_for_user_id) rescue nil
    # Hash with delegate id and number of times it has occurred
    # If delegate is already present, count > 1
    # delegate_with_count = Hash[delegate_ids.group_by(&:itself).map {|k,v| [k, v.size] }] rescue nil
    # Ids of repeated delegated_for_users
    # repeated_delegated_for_users = delegate_with_count.select{|k,v| v > 1}.keys rescue nil
    return delegate_ids
  end
end
class User::AssociatedUsers::Base < User::Base
  attr_accessor :document, :associated_users, :trails, :users_before, :amount

  # `amount` needs to be passed for finding eligible reviewers from levels
  # Since amount is stored in different attributes for different documents,
  # it has to be provided separately

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if params.blank?
      add_message :error, 'Document not found'
    end
  end

  def init
    self.document = params[:document]
    if self.document.present?
      self.trails = document.trails
    end
    self.user_before = params[:user_before]
    self.amount = params[:amount]
  end

end
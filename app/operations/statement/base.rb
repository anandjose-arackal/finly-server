class Statement::Base < BaseOperation

  attr_accessor :selected_user

  class Statement::Base::StatementPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :items

    def init
      self.items = params[:items]
    end
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "Invalid parameters. Try again"
    end
  end

  def load_selected_user
    if personal_view?
      self.selected_user = self.user
      return
    end
    user_op = User::Team::Index.new(user, params)
    user_result = user_op.run
    unless user_op.success?
      self.messages[:error] = user_op.messages[:error]
      return
    end
    user_id = (params[:id] or params[:user_id])
    self.selected_user = user_result.users.with_id(user_id).first rescue nil
    if self.selected_user.blank?
      messages[:error] << 'User not found'
    end
  end

end
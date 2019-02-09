class BankTransfer::AutocompleteController < BaseControllers::WebBase

  def user
    @users = User::Team::Index.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end
end

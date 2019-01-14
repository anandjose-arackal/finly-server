class BankTransfer::AutocompleteController < BaseControllers::PublicBase

  def user
    @users = User::Team::Index.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end
end

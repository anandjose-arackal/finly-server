class AdminUsers::ExpensesController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!



end
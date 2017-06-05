class ApiApplicationController < ApplicationController

  before_action { block_foreign_hosts(WhitelistedIpType.id_for(:api)) }
  before_action :authenticate_user!
  allow_oauth!

end
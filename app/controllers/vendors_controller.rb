class VendorsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def filter_config
    @result = Vendors::FilterConfig.(current_user, params)
    respond
  end

  def index
    @result = Vendors::Index.(current_user, params)
    respond
  end

  def show
    @result = Vendors::Show.(current_user, params)
    respond
  end

  def new_vendor_config
    @result = Vendors::NewVendorConfig.(current_user, params)
    respond
  end

  def create
    @result = Vendors::Create.(current_user, params)
    respond
  end

  def update
    @result = Vendors::Update.(current_user, params)
    respond
  end

  def submit
    @result = Vendors::Submit.(current_user, params)
    respond
  end

  def retract
    @result = Vendors::Retract.(current_user, params)
    respond
  end

  def reject
    @result = Vendors::Reject.(current_user, params)
    respond
  end

  def approve
    @result = Vendors::Approve.(current_user, params)
    respond
  end

  def take_control
    @result = Vendors::TakeControl.(current_user, params)
    respond
  end

  def return_control
    @result = Vendors::ReturnControl.(current_user, params)
    respond
  end

  def penny_test
    @result = Vendors::PennyTest.(current_user, params)
    respond
  end
end
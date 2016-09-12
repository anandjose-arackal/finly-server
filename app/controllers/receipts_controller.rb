class ReceiptsController < ApplicationController

  before_action :authenticate_user!


  def index
    @receipts = Receipt::Index.new(current_user, params).run.receipts

    respond_to do |format|
      format.html {}
      format.json {}
    end
  end

  def create
    create_op = Receipt::Create.new(current_user, params)
    @result = create_op.run
    if @result
      flash[:success] = "Receipt created."
    else
      flash[:failure] = "Error. Try again."
    end
    respond_to do |format|
      # format.html { redirect_to (request.referrer or receipts_path) }
      # format.js do
      #   @receipts = Receipt::Index.new(current_user, params).run.receipts
      #   render 'receipts/index_update'
      # end
      format.json { render json: {"success": true} }
    end
  end

  def destroy
    destroy_op = Receipt::Create.new(current_user, params)
    @result = destroy_op.run
    if @result
      flash[:success] = "Receipt created."
    else
      flash[:failure] = "Error. Try again."
    end
    respond_to do |format|
      # format.html { redirect_to (request.referrer or receipts_path) }
      # format.js do
      #   load_receipts
      #   render 'receipts/index_update'
      # end
      format.json { render json: {"success": true} }
    end
  end



  def update
    update_op = Receipt::Update.new(current_user, params)
    @result = update_op.run
    if @result
      flash[:success] = "Updated"
    else
      flash[:failure] = "Failed."
    end
    respond_to do |format|
      format.json { render json: {"success": true} }
    end
  end


end

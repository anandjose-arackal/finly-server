class CreditNoteFormsController < BaseControllers::WebBase
  layout 'trailblazers'

  def show
    endpoint Docs::I2P::CreditNotes::Ops::Show
  end

  def update
    endpoint Docs::I2P::CreditNotes::Ops::Update
  end

  def save_and_submit
    @op = Docs::I2P::CreditNotes::Ops::SaveAndSubmit.({params: params.to_unsafe_h, current_user: current_user})
    respond_to do |format|
      format.json {}
    end
  end
end
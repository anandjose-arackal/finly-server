class Feedback::Create < BaseOperation
  attr_accessor :feedback_params

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:feedback].blank? or params[:feedback][:feedback_type_id].blank?
      add_message :error, 'Error capturing feedback, please try again'
      return
    end
    if params[:feedback][:content].blank?
      add_message :error, 'Content cannot be blank'
    end
  end

  def init
    self.feedback_params = feedback_strong_params
  end

  def validate
    if feedback_params.blank?
      add_message :error, 'Content cannot be blank'
    end
  end

  def process
    feedback = user.feedbacks.build feedback_params
    unless feedback.save
      add_message :error, feedback.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Thank you for your feedback'
  end

  private
  def feedback_strong_params
    params.require(:feedback).permit(:feedback_type_id, :content)
  end

end
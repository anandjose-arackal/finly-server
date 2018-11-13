class ReviewalLevels::Destroy < ReviewalLevels::Base

  attr_accessor :level

  def init
    id = params[:id] || params[:level_id]
    self.level = ReviewalLevel.find_by id: id
  end

  def validate
    if self.level.blank?
      add_message :error, "Reviewal Level not found"
    end
  end

  def process
    unless self.level.destroy
      add_message :error, self.level.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Reviewal level destroyed"
  end

end
class AnnouncementToggle < ApplicationToggle

  def product_stash
    feature_flag 'release/announcement#product_stash', false
  end

end
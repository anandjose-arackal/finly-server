class BBPS::Response < NonPersistentModel
  attr_accessor :message_code, :status, :error_code, :error_desc

  def success?
    false
  end

  class BBPS::Response::Success < BBPS::Response

    def success?
      true
    end

  end

  class BBPS::Response::Success < BBPS::Response


  end

end
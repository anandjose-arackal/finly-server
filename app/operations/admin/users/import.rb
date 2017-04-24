class Admin::Users::Import < Admin::Users::Base

  # include ImportUtil

  attr_accessor :file, :result_hash, :header, :import_fields, :sheet, :invitee



end
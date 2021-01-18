class ExportManagerToggle < ApplicationToggle

  def templates_enabled?
    feature_flag 'release/export_manager#templates_enabled', false
  end

end
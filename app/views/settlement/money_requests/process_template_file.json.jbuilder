if @result.just_show_excel
	json.errors_file_path @result.result_file_path
end
json.redirect @result.redirect
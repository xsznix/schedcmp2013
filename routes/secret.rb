class MyApp < Sinatra::Application

	get "/secret/counter" do
		erb :counter
	end

	post "/secret/addcourses" do
		halt "Invalid Password." unless params[:password] == "" # CONSTANT REQUIRED
		course_number_list = params[:numbers].split(",").map! do |course_number|
			course_number.strip.to_i
		end
		set_course_numbers_same(course_number_list)
		"Success."
	end

	get "/secret/addcourses" do
		erb :coursenumbers
	end

end
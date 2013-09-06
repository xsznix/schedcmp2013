class MyApp < Sinatra::Application
	
	def get_user
		s = Student.first :id => session[:id]
		return s if s.nil?
		# auto logout after 12 hours
		now = Date.today
		if now - s.last_seen > 43200.0
			s = nil
		end
		s
	end

	get "/auth/:provider/callback" do
	  auth = request.env['omniauth.auth']
	  # # debug
	  # puts '======================================='
	  # puts auth.to_yaml
	  # puts '======================================='
	  
	  stud = Student.first :uid => auth['uid']
	  if stud.nil?
		redirect "/"
	  else
		# update information
		split_name = auth['info']['name'].split
		stud.first_name = split_name.first
		stud.last_name = split_name[1..-1].join(' ')
		stud.avatar = auth['info']['image']
	  end
	  stud.save
	  
	  # stud.errors.each do |err|
	  #   puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
	  #   puts err
	  #   puts '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
	  # end

	  session[:id] = stud.id
	  if stud.school == INDETERMINATE
		redirect :newuser
	  else
		redirect :compare
	  end
	end

end
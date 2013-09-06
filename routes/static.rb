class MyApp < Sinatra::Application

	get "/" do
		@student = get_user
		unless(params[:ref].nil?)
			session[:ref] = params[:ref]
		end
		erb :index
	end

	get "/logout" do
		session.clear
		redirect "/"
	end

	get "/logout/:target" do
		session.clear
		redirect "/#{params[:target]}"
	end

	get "/register" do
		@student = get_user
		redirect "/compare" unless @student.nil?
		erb :register
	end

	get "/developers" do
		@student = get_user
		erb :developers
	end

	get "/contact" do
		@student = get_user
		erb :contact
	end

end
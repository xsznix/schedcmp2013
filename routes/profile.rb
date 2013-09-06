class MyApp < Sinatra::Application

	get "/user/:id" do
		@student = get_user
		redirect "/" if @student.nil?

		@user = Student.first :id => params[:id]

		if @user.nil?
			halt "User not found."
		end

		blocks_remaining = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
		@schedule = []
		@blocks_sharing = []

		@user.scheduled_courses.each do |course|
			fake_block = course.block + 8 * (course.semester - 1)
			blocks_remaining.delete fake_block

			@schedule[fake_block - 1] = {
				name: course.course_name_no_block,
				courseid: course.courseid,
				block: course.block,
				profile: course.profile
			}

			if course.students_sharing.include? @student
				@blocks_sharing << course.course_name_no_block
			end
		end

		blocks_remaining.each do |block|
			@schedule[block-1] = {
				name: "Unknown",
				courseid: nil,
				block: block,
				profile: ""
			}
		end

		@blocks_sharing.uniq!

		erb :profile
	end

	get "/course/:school/:id" do
		@student = get_user
		redirect "/" if @student.nil?
		
		school_sym = params[:school].to_sym
		@school_long = LONG_SCHOOL_NAMES[school_sym]
		@school = SCHOOL_NAMES[school_sym]

		@course = {
			:name => REDIS.get(params[:id]),
			:id => params[:id]
		}

		@course[:name] = 'Unknown Course' if @course[:name].nil?

		blocks_remaining = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
		@students_sharing = []

		# get lists of courses that are taught together with this course
		@shared_courses = []
		shared_course_numbers = get_same_courses params[:id]
		unless shared_course_numbers == params[:id]
			shared_course_numbers.each do |num|
				@shared_courses << {
					:name => REDIS.get(num),
					:id => num,
					:profile => "/course/#{params[:school]}/#{num}"
				}
			end
		end

		# get all students taking the course
		scheds = ScheduledCourse.all(:courseid => @course[:id]).collect do |sc|
			sc.student.school == school_sym ? sc : nil
		end
		scheds.delete_if(&:nil?)

		# get students in each block
		(1..16).each do |i|
			@students_sharing[i] = scheds \
				.select { |x| x.block + 8 * (x.semester - 1) == i } \
				.map { |x| x.student } \
				.sort { |s1, s2| s1.name <=> s2.name }
		end

		@numstudents = @students_sharing.flatten.uniq.delete_if(&:nil?).length

		# render
		erb :course
	end

end
class MyApp < Sinatra::Application

	get "/newuser" do
		# authenticate
		@student = get_user
		redirect "/" if @student.nil?

		erb :newuser
	end

	post "/newuser" do
		@student = get_user
		redirect "/" if @student.nil?

		# update student info
		@student.school = params[:school].to_sym
		@student.gradyear = params[:gradyear].to_i
		@student.save

		if(@student.save == false)
			erb :newuser
		end
		# check for errors
		unless @student.errors.first.nil?
			@error = @student.errors.first.token
			erb :newuser
		end

		# go to the next step
		redirect :edit
	end

	get "/edit" do
		@student = get_user
		redirect "/" if @student.nil?
		redirect "/newuser" if @student.school == INDETERMINATE

		blocks_remaining = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
		@courses = [] 
		@student.scheduled_courses.each do |scheduled_course|
			block = (scheduled_course.semester == 1) ? scheduled_course.block : scheduled_course.block + 8
			blocks_remaining.delete(block)
			section_text = scheduled_course.section.nil? ? "" : "-#{scheduled_course.section}"
			course_id = "#{scheduled_course.courseid}#{section_text}"
			@courses[block-1] = { block: block, course_id: course_id, course_name: REDIS.get(course_id), real_block: scheduled_course.block }
		end

		blocks_remaining.each do |block|
			real_block = (block - 1) % 8 + 1

			@courses[block-1] = { block: block, course_id: "", course_name: "", real_block: real_block}
		end

		@courses.sort! { |x, y| x[:block] <=> y[:block] }

		puts @courses.inspect
		
		erb :edit
	end

	get "/coursename/:cid" do
		if((/\d/ =~ params[:cid].strip[0]) == nil)
			halt "Must enter course ID, not course name."
		elsif(params[:cid].length < 4)
			halt "Course ID too short."
		end
		matches = /(\d{4,6}\.?.{4}?(?:\.?:X|Y?))(?:A|B?)\s?-?\s?(\d)?/i.match(params[:cid].strip)
		course_name = REDIS.get(matches[1])
		if(course_name == nil)
			halt "Unknown Course"
		else
			halt course_name.to_s
		end
	end

	post "/edit" do
		@student = get_user
		redirect "/" if @student.nil?
		@student.scheduled_courses.destroy

		@student.public = params[:public] == "yes"
		@student.save

		# it's 1-16 because every number after 8, the real block becomes block - 8 and switches to second semester
		(1..16).each do |block|
			semester = (block <= 8) ? 1 : 2
			real_block = (block <= 8) ? block : block - 8
			options = { :student => @student }
			# TODO: handle LASA course numbers
			if(params[block.to_s].strip != "")
				matches = /(\d{4,6}\.?.{4}?(?:\.?:X|Y?))(?:A|B?)\s?-?\s?(\d)?/i.match(params[block.to_s].strip)
				options.merge!(
					courseid: matches[1], # becuase the course has more digits
					section: matches[2],
					block: real_block,
					semester: semester
				)
			end
			unless(!options[:block] || !options[:semester])
				ScheduledCourse.create(options)
			end
		end

		redirect "/compare"
	end

	get "/compare" do
		@student = get_user
		redirect "/" if @student.nil?
		redirect "/newuser" if @student.school == INDETERMINATE
		redirect "/edit" if @student.scheduled_courses.empty?
		blocks_remaining = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]

		@list_of_students = []
		@student.scheduled_courses.each do |scheduled_course|
			fake_block = (scheduled_course.semester == 1) ? scheduled_course.block : scheduled_course.block + 8
			
			blocks_remaining.delete(fake_block)
			@list_of_students[fake_block] = { 
				name: scheduled_course.course_name,
				profile: scheduled_course.profile,
				students: scheduled_course.students_sharing,
				semester: scheduled_course.semester,
				block: scheduled_course.block
			}
		end
		
		blocks_remaining.each do |block|
			real_block = (block - 1) % 8 + 1
			semester = (block <= 8) ? 1 : 2
			@list_of_students[block] = { 
				name: "Block #{real_block} (no information entered)",
				profile: '',
				students: [], 
				semester: semester,
				block: real_block 
			}
		end

		#puts @list_of_students.inspect

		erb :compare
	end

	get "/search" do
		@student = get_user
		redirect "/" if @student.nil?

		@query = params[:query]

		# search results
		unless @query.nil?
			split_name = @query.split
			@name_matches = []
			@course_match = []
			
			# user search by uid
			if not /^\d*$/.match(@query).nil? # TODO parse LASA course numbers
				# Facebook ID
				@name_matches = Student.all :uid => @query.to_i
				@found = !(@name_matches.empty?)
			end

			# course search by identifier
			if not /(\d{4,6}\.?.{4}?(?:\.X|Y?))(?:A|B?)\s?-?\s?(\d)?/i.match(@query.strip).nil?
				@name_matches = []
				# course number
				coursematch = REDIS.get(@query)
				unless coursematch.nil?
					@course_match << { :id => @query, @name => REDIS.get(@query), :numtaking =>
						ScheduledCourse.all(:courseid => @query) \
						.select { |x| x.student.school == @student.school } \
						.map { |x| x.student }.uniq.length }
				end
				@found = @found || !(@course_match.empty?)
			end

			# fuzzy user search
			@name_matches = Student.fuzzy_find(@query)
			@found = @found || @name_matches.empty?

			# fuzzy course name search
			if @student.school == LASA
				fuzzy_courses = LASA_COURSE_MAP.find(@query)
				fuzzy_courses.each do |fuzz|
					num = LASA_COURSE_HASH[fuzz[0]]
					@course_match << { :id => num, :name => REDIS.get(num), :numtaking =>
						ScheduledCourse.all(:courseid => num) \
						.select { |x| x.student.school == @student.school } \
						.map { |x| x.student }.uniq.length }
				end
			else
				fuzzy_courses = COURSE_MAP.find(@query)
				fuzzy_courses.each do |fuzz|
					num = COURSE_HASH[fuzz[0]]
					@course_match << { :id => num, :name => REDIS.get(num), :numtaking =>
						ScheduledCourse.all(:courseid => num) \
						.select { |x| x.student.school == @student.school } \
						.map { |x| x.student }.uniq.length }
				end
			end

			@found = @found || !(@course_match.empty?)
		end

		erb :search
	end

	error do
		"Whoa there. Something went wrong on our side. Try to see if you entered any paramters correctly. If you still cannot proceed, please contact admin@schedulecomparinator.com so we can investigate. Sorry :(."
	end

end

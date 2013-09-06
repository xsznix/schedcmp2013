class ScheduledCourse
	include DataMapper::Resource

	property :id,       Serial

	# Real Schedule
	property :courseid, String, :length => 15
	property :section,  Integer

	#Both
	property :block,    Integer
	property :semester, Integer

	belongs_to :student

	def students_sharing
		students_sharing_from_schedule.sort { |s1, s2| s1.name <=> s2.name }
	end

	def students_sharing_from_schedule
		students = []
		course_numbers = get_same_courses(self.courseid)

		section_array = [nil, self.section]
		if(self.section.nil?)
			section_array = section_array + [1,2,3,4,5,6,7,8,9]
		end

		students = ScheduledCourse.all(
			courseid: course_numbers,
			block: self.block,
			semester: self.semester,
			section: section_array,
			student: {
				school: self.student.school
			}
		).map(&:student)
	end

	def course_name
		if self.courseid.nil?
			return "Block #{self.block.to_s}"
		else
			n = REDIS.get(self.courseid)
			return n.nil? ? "Block #{self.block.to_s}: Unknown Course" : "Block #{self.block.to_s}: #{n}"
		end
	end

	def course_name_no_block
		id = REDIS.get(self.courseid)
		id.nil? ? "Unknown" : id
	end

	def profile
		"/course/#{self.student.school.to_s}/#{self.courseid}"
	end
end
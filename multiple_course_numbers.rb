require 'json'

def set_course_numbers_same(course_numbers)
	relationship_key = nil
	course_numbers.each do |course_number|
		possible_relationship_key = REDIS.get("getrelationship_#{course_number}")
		unless(possible_relationship_key.nil?)
			relationship_key = possible_relationship_key
			break
		end
	end

	if(relationship_key.nil?)
		relationship_key = "relationship_#{REDIS.incr("number_of_relationships")}"
		REDIS.set(relationship_key, course_numbers.to_json)
	else
		existing_course_numbers = JSON.parse(REDIS.get(relationship_key))
		relationship_with_new_numbers = (existing_course_numbers + course_numbers).uniq!
		REDIS.set(relationship_key, relationship_with_new_numbers.to_json)
	end

	course_numbers.each do |course_number|
		REDIS.set("getrelationship_#{course_number}", relationship_key)
	end

	true
end

def get_same_courses(course_number)
	relationship_key = REDIS.get("getrelationship_#{course_number}")
	return course_number if relationship_key.nil?

	same_classes = JSON.parse(REDIS.get(relationship_key))

	return same_classes
end
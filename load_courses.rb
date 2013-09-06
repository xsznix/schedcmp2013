require 'csv'

REDIS.keys.each do |key|
	REDIS.del(key) if (/.*relationship.*/ =~ key).nil?
end

c_id_counter = 0

CSV.foreach("course_names.csv") do |row|
	REDIS.set(row[0], row[1])
	COURSE_HASH[c_id_counter] = row[0]
	COURSE_MAP.put(row[1], c_id_counter)
	c_id_counter += 1
end

CSV.foreach("lasa_course_names.csv") do |row|
	REDIS.set(row[0], row[1])
	LASA_COURSE_HASH[c_id_counter] = row[0]
	LASA_COURSE_MAP.put(row[1], c_id_counter)
	c_id_counter += 1
	#comment
end
class StudentTrigram
	include DataMapper::Resource
	property :id, Serial
	property :student_id, Integer, :index => true
	property :token, String, :required => true, :length => 3, :index => true
end
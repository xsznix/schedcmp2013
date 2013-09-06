class Student
	include DataMapper::Resource
	include FuzzySearch
	
	property :id,          Serial
	property :uid,         String,  :required => true # Facebook/Google ID
	property :provider,    String # Authentication provider
	property :first_name,  String,  :required => true
	property :last_name,   String,  :required => true
	property :school,      Enum[WESTWOOD, MCNEIL, ROUNDROCK, STONYPOINT, CEDARRIDGE, LASA, INDETERMINATE], :required => true, :default => INDETERMINATE
	property :gradyear,    Integer, :default => 99
	property :last_seen,   Date,    :required => true, :default => Date.today
	property :hac_url,     String,  :length => 256
	property :referrals,   Integer, :default => 0
	property :avatar,      String,  :length => 256
	property :ext_profile, String,  :length => 256
	property :public,      Boolean, :default => true

	act_as_fuzzy_search :first_name, :last_name

	def self.normalize(word)
		word.downcase
	end

	has n, :scheduled_courses

	def name
		"#{self.first_name} #{self.last_name}"
	end

	def referral_link
		"http://www.schedulecomparinator.com/?ref=#{self.id}"
	end

	def profile
		"/user/#{self.id}"
	end

	def school_name
		SCHOOL_NAMES[self.school]
	end

	def long_school_name
		LONG_SCHOOL_NAMES[self.school]
	end

	def external_link
		if self.provider == "facebook"
			"https://facebook.com/#{self.uid}"
		elsif self.provider == "gplus"
			self.ext_profile
		end
	end

	def avatar_large
		if self.provider == "facebook"
			"http://avatars.io/facebook/" + self.uid + "?size=large"
		elsif self.provider == "gplus"
			self.avatar
		end
	end

	def provider_name
		{ "facebook" => "Facebook", "gplus" => "Google+"}[self.provider]
	end
end
require 'bundler/setup'
Bundler.require(:default)

require 'uri'
# disable
require 'net/http'
# require 'rack-flash'
# require 'sinatra/redirect_with_flash'

# constants
FB_APP_ID = "" # CONSTANT REQUIRED
FB_APP_SECRET = "" # CONSTANT REQUIRED
GOOGLE_CLIENT_ID = "" # CONSTANT REQUIRED
GOOGLE_CLIENT_SECRET = "" # CONSTANT REQUIRED

WESTWOOD = :ww
MCNEIL = :mn
ROUNDROCK = :rr
STONYPOINT = :sp
CEDARRIDGE = :cr
LASA = :lasa
INDETERMINATE = :ind

SCHOOL_NAMES = {
	:ww => "Westwood",
	:mn => "McNeil",
	:rr => "Round Rock",
	:sp => "Stony Point",
	:cr => "Cedar Ridge",
	:lasa => "LASA"
}

LONG_SCHOOL_NAMES = {
	:ww => "Westwoood High School",
	:mn => "McNeil High School",
	:rr => "Round Rock High School",
	:sp => "Stony Point High School",
	:cr => "Cedar Ridge High School",
	:lasa => "Liberal Arts and Science Academy"
}

set :partial_template_engine, :erb
set :dump_errors, true
set :static_cache_control, [:public, max_age: 60 * 30]

uri = URI.parse(ENV["REDISCLOUD_URL"] || "redis://localhost:6379/" )
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

require 'blurrily/map'
COURSE_MAP = Blurrily::Map.new
LASA_COURSE_MAP = Blurrily::Map.new
COURSE_HASH = Hash.new
LASA_COURSE_HASH = Hash.new

# OmniAuth shiz
#use Rack::Session::Cookie
use OmniAuth::Builder do
  #provider :twitter, 'XAPucW9C0kZvuWsT6NivA', 'G295qiVP43vbSZryu05BjKPtjlN9B6n45uCHwhizkM'
  provider :facebook, FB_APP_ID, FB_APP_SECRET
  provider :gplus, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, :scope => "userinfo.profile"
end

class MyApp < Sinatra::Application
	enable :sessions
	# use Rack::Flash, :sweep => true
	use Rack::Static, :urls => ["/public"]

	set :session_secret, '' # CONSTANT REQUIRED

end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
require_relative 'load_courses'
require_relative 'multiple_course_numbers'
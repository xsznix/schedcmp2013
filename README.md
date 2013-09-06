# Schedule Comparinator 2013

An archive of the Schedule Comparinator 2013 production code.

## Installing

It is assumed that you are using a UNIX-based system (i.e. anything other than Windows).

1. Install [rvm](https://rvm.io/).
2. Install Ruby. Versions 1.9.3 and 2.0.0 have been tested.
3. Install Bundler using the command `$ gem install bundler`
4. Install the required gems using the command `$ bundle install` in the root directory of the repo.

The development environment will run a local Redis server and an instance of SQLite.

### Keys

You will need to create Facebook and Google+ apps and fill in the keys in `app.rb:11-14`. In addition, search the source files for `# CONSTANT REQUIRED` to find other places where some constants need to be filled in. These include the session secret, the password to join together courses, and the NewRelic license key.

## Developing

To start the server, run the command `bundle exec thin -R config.ru start` in the root directory of the repo.

## Deploying

We're noobs, so we used Heroku. For Schedule Comparinator 2013, we used the addons JustOneDB, PaperTrail, RedisCloud, and NewRelic. If you want to deploy to a VPS or dedicated server, good luck.

## License

Copyright (c) 2013, Yash Aggarwal, Justin Lai, Connor Statham, and Xuming Zeng.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

  Neither the name of the {organization} nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
# = pog.rb
#
# Copyright (c) 2007 Operis Systems, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# == Using POG in your application
#
# 1. Install the gem
#      %> gem install pog
# 2. Add the following line to your files
#      require 'pog'
# 3. You're done!
#

require File.join( File.dirname(__FILE__), 'character_ranges.rb' )
require File.join( File.dirname(__FILE__), 'random_string_generator.rb' )
require File.join( File.dirname(__FILE__), 'salt.rb' )
require File.join( File.dirname(__FILE__), 'password.rb' )
require File.join( File.dirname(__FILE__), 'password_tests.rb' )
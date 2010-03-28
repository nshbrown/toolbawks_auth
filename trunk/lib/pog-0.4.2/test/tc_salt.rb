require 'test/unit'
require 'base64'
require File.join( File.dirname(__FILE__), '..', 'lib', 'pog.rb' )

TEST_PASS = '/O0op;G75wu3saMv|N9&DA?I*/!3-gqHUe9{VZL{M3YVoYUQ]6q{]Poz%c)V#T,i=g.G8>&'
TEST_SALT = 'foobar'

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

class TC_Salt < Test::Unit::TestCase
  
  def test_new
    salt = Salt.new( TEST_SALT )
    assert_equal :end, salt.placement
    
    salt = Salt.new( TEST_SALT, :beginning )
    assert_equal :beginning, salt.placement
    
    salt = Salt.new( :new, :end, :length => 8 )
    assert_not_nil salt.string
    assert_equal 8, salt.string.length
    assert_equal :end, salt.placement
  end
  
  def test_generate_str
    for len in 0..32
      salt = Salt.generate_str( len )
      assert salt.length == len, "test_generate_salt failed for length #{len}"
    end
  end
  
  def test_salt_password
    salt = Salt.new( TEST_SALT, :beginning )
    assert_equal  TEST_SALT + TEST_PASS, 
                  salt.salt_password( TEST_PASS ),
                  "test_salt_password failed for beginning"
    
    salt = Salt.new( TEST_SALT, :end )
    assert_equal  TEST_PASS + TEST_SALT, 
                  salt.salt_password( TEST_PASS ),
                  "test_salt_password failed for end"
    
    salt = Salt.new( "foobar", :split )
    assert_equal  'foo' + TEST_PASS + 'bar',
                  salt.salt_password( TEST_PASS ),
                  "test_salt_password failed for even split"
    
    salt = Salt.new( 'fooba', :split )
    assert_equal  'fo' + TEST_PASS + 'oba',
                  salt.salt_password( TEST_PASS ),
                  "test_salt_password failed for odd split"
   
 end
end
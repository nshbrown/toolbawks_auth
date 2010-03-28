require 'test/unit'
require File.join( File.dirname(__FILE__), '..', 'lib', 'pog.rb' )
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

class TC_PasswordTests < Test::Unit::TestCase
  def test_length
    tests = get_password_tests({ :bad => 'fubar', :good => 'foobar', :extra_good => 'foobar0' }, 
                               { :test_length => 6 })
                      
    make_assertions_on_tests tests, :test_length
  end
  
  def test_minimum_alphas
    tests = get_password_tests({ :bad => 'f00', :good => 'fo0', :extra_good => 'foo' }, 
                               { :test_minimum_alphas => 2 })
                      
    make_assertions_on_tests tests, :test_minimum_alphas
  end
  
  def test_maximum_alphas
    tests = get_password_tests({ :bad => 'foo', :good => 'fo0', :extra_good => 'f00' }, 
                               { :test_maximum_alphas => 2 })
                      
    make_assertions_on_tests tests, :test_maximum_alphas
  end
  
  def test_minimum_upper_alphas
    tests = get_password_tests({ :bad => 'Foo', :good => 'FOo', :extra_good => 'FOO' }, 
                               { :test_minimum_upper_alphas => 2 })
                      
    make_assertions_on_tests tests, :test_minimum_upper_alphas
  end
  
  def test_maximum_upper_alphas
    tests = get_password_tests({ :bad => 'FOO', :good => 'FOo', :extra_good => 'Foo' }, 
                               { :test_maximum_upper_alphas => 2 })
                      
    make_assertions_on_tests tests, :test_maximum_upper_alphas
  end
  
  def test_minimum_lower_alphas
    tests = get_password_tests({ :bad => 'FOo', :good => 'Foo', :extra_good => 'foo' }, 
                               { :test_minimum_lower_alphas => 2 })
                      
    make_assertions_on_tests tests, :test_minimum_lower_alphas
  end
  
  def test_maximum_lower_alphas
    tests = get_password_tests({ :bad => 'foo', :good => 'Foo', :extra_good => 'FOo' }, 
                               { :test_maximum_lower_alphas => 2 })
                      
    make_assertions_on_tests tests, :test_maximum_lower_alphas
  end
  
  def test_minimum_numerals
    tests = get_password_tests({ :bad => 'fo0', :good => 'f00', :extra_good => '000' }, 
                               { :test_minimum_numerals => 2 })
                      
    make_assertions_on_tests tests, :test_minimum_numerals
  end
  
  def test_maximum_numerals
    tests = get_password_tests({ :bad => '000', :good => 'f00', :extra_good => 'fo0' }, 
                               { :test_maximum_numerals => 2 })
                      
    make_assertions_on_tests tests, :test_maximum_numerals
  end
  
  def test_minimum_non_alphanumeric
    tests = get_password_tests({ :bad => 'fo@', :good => 'f@@', :extra_good => '@@@' }, 
                               { :test_minimum_non_alphanumeric => 2 })
                      
    make_assertions_on_tests tests, :test_minimum_non_alphanumeric
  end
  
  def test_maximum_non_alphanumeric
    tests = get_password_tests({ :bad => '@@@', :good => 'f@@', :extra_good => 'fo@' }, 
                               { :test_maximum_non_alphanumeric => 2 })
                      
    make_assertions_on_tests tests, :test_maximum_non_alphanumeric
  end
  
  def test_run
    tests = PasswordTests.new( 'FooBar', :test_length => 8, 
                                         :test_minimum_alphas => 2 )

    assert_equal({ :test_length => false, 
                   :test_minimum_alphas => true }, tests.run)
  end
  
  def test_repetitions
    assert PasswordTests.repetitions('fobar').empty?
    
    assert_equal( {'o'=>1}, 
                  PasswordTests.repetitions('foobar') )
    
    assert_equal( {'o'=>3, 'oo'=>1}, 
                  PasswordTests.repetitions('fooboo') )
    
    assert_equal( {'f' => 1, 'o'=>3, 'oo'=>1, 'foo'=>1}, 
                  PasswordTests.repetitions('foofoo') )
  end
  
  def test_qualitative_strength
    assert_operator 0, :== , PasswordTests.qualitative_strength( '123456' )
    
    assert_operator 0, :== , PasswordTests.qualitative_strength( 'foo' )
    
    assert_operator 0, :<= , PasswordTests.qualitative_strength( 'fooo' )
  end
  
  def test_entropy
    assert_operator 3.3, :< , PasswordTests.entropy( '1' )
    
    assert_operator 4.7, :< , PasswordTests.entropy( 'f' )
    
    assert_operator 5.0, :< ,PasswordTests.entropy( '$' )
    
    assert_operator 6.6, :< ,PasswordTests.entropy( '12' )
  end
  
  private
  
  ##
  # Gets a hash of PasswordTests classes for each of the given passwords in the
  # test_password_hash with the given test_hash
  #
  def get_password_tests( test_password_hash , test_hash )
    tests = Hash.new { |hash, key| 
      hash[key] = PasswordTests.new( test_password_hash[key], test_hash ) }
    test_password_hash.each_key { |name| tests[name] }
    return tests
  end
  
  ##
  # Executes the given method on the cases :bad, :good, and :extra_good and 
  # asserts that :bad is false, and :good and :extra_good are true
  #
  def make_assertions_on_tests( tests, method )
    assert_equal false, tests[:bad].__send__(        method )
    assert_equal true,  tests[:good].__send__(       method )
    assert_equal true,  tests[:extra_good].__send__( method )
  end
end
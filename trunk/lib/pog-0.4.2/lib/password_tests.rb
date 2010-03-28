##
# = password_tests.rb
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

##
# = PasswordTests Class
# 
# PasswordTests provides functionality for testing strength of passwords
#
# === Usage
#
# 1. Pass the constructor either a Password object or a String (or anything 
#    that can be converted to a String using +to_s+).
# 2. Pass the constructor a Hash of tests and their corresponding parameters.
#    The tests are method names of the PasswordTests object.
# 3. Execute the +run+ method to execute the tests.
# 4. Inspect the returned +Hash+ to verify pass/fail for each test.
#
# === Examples
# 
# Test the length of the password
# 
#   tests = PasswordTests.new( Password.new('foobar'), :test_length => 8)
#   results = tests.run  => {:test_length => false}
# 
# Test the length of the password and for at least 2 upper case alpha 
# characters.
# 
#   tests = PasswordTests.new( 'FooBar', :test_length => 8, 
#                                        :test_minimum_alphas => 2 )
#   results = tests.run  => {:test_length => false, 
#                            :test_minimum_alphas => false}
# 
# === Tests
# 
# These are the currently implemented tests; however, feel free to mix-in your
# own or extend the PasswordTests class.
#
# test_length::                    minimum length
# test_minimum_alphas::            minimum number of alpha characters (upper 
#                                  and lower case)
# test_maximum_alphas::            maximum number of alpha characters (upper 
#                                  and lower case)
# test_minimum_upper_alphas::      minimum number of uppercase alpha 
#                                  characters
# test_maximum_upper_alphas::      maximum number of uppercase alpha 
#                                  characters
# test_minimum_lower_alphas::      minimum number of lowercase alpha 
#                                  characters
# test_maximum_lower_alphas::      maximum number of lowercase alpha 
#                                  characters
# test_minimum_numerals::          minimum number of numeric characters
# test_maximum_numerals::          maximum number of numeric characters
# test_minimum_non_alphanumeric::  minimum number of non-alphanumeric 
#                                  characters (symbols)
# test_maximum_non_alphanumeric::  maximum number of non-alphanumeric 
#                                  characters (symbols)
# 
# === Calculating the qualitative strength of a password
# 
#   PasswordTests.qualitative_strength( '123456')       => 0
#   PasswordTests.qualitative_strength( 'foo' )         => 0
#   PasswordTests.qualitative_strength( 'fooo' )        => 2
#   PasswordTests.qualitative_strength( 'foobar' )      => 12
#   PasswordTests.qualitative_strength( '1fo0^*bar9' )  => 95
# 
# 
# === Calculating the entropy of a password
# 
#   Password.entropy('1')           => 3.32192809488736
#   Password.entropy('123456')      => 19.9315685693242
#   Password.entropy('foobar')      => 28.2026383088466
#   Password.entropy('1fo0^*bar9')  => 61.0852445677817

class PasswordTests
  ##
  # Initialize the password tests (in +test_params+) with the given +password+.
  # If +test_params+ is left out or is an empty Hash, the medium-low default will
  # be used from PasswordTests.default_test_params
  #
  # Example: The following would run the test_length and test_minimum_alphas 
  #          tests (and both would fail on the given password)
  # 
  #   tests = PasswordTests.new( 'FooBar', :test_length => 8, 
  #                                        :test_minimum_alphas => 2 )
  #
  def initialize( password, test_params = {} )
    @password = password.to_s
    if test_params.empty?
      @test_params = default_test_params
    else
      @test_params = test_params
    end
  end
  
  ##
  # Run the tests.
  # 
  # The results are returned in a Hash with the key as the test, and the value
  # as whether or not the test passed
  #
  # Example:
  #
  #   tests = PasswordTests.new( 'FooBar', :test_length => 8, 
  #                                        :test_minimum_alphas => 2 )
  #   results = tests.run  => {:test_length => false, 
  #                            :test_minimum_alphas => false}
  #
  def run
    results = Hash.new { |h,k|         h[k] = false }
    @test_params.each { |test,param|  results[test] = send(test, param) }
    return results
  end
  
  ##
  # Tests the length of the password
  #
  def test_length( *params )
    params[0] ||= @test_params[current_method_name]
    @password.length >= params[0]
  end
  
  ##
  # Tests for a minimum number of alpha characters
  #
  def test_minimum_alphas( *params )
    params[0] ||= @test_params[current_method_name]
    minimum_test( /[A-Za-z]/, params[0] )
  end
  
  ##
  # Tests for a maximum number of alpha characters
  #
  def test_maximum_alphas( *params )
    params[0] ||= @test_params[current_method_name]
    maximum_test( /[A-Za-z]/, params[0] )
  end
  
  ##
  # Tests for a minimum number of upper case alpha characters
  #
  def test_minimum_upper_alphas( *params )
    params[0] ||= @test_params[current_method_name]
    minimum_test( /[A-Z]/, params[0] )
  end
  
  ##
  # Tests for a maximum number of upper case alpha characters
  #
  def test_maximum_upper_alphas( *params )
    params[0] ||= @test_params[current_method_name]
    maximum_test( /[A-Z]/, params[0] )
  end
  
  ##
  # Tests for a minimum number of lower case alpha characters
  #
  def test_minimum_lower_alphas( *params )
    params[0] ||= @test_params[current_method_name]
    minimum_test( /[a-z]/, params[0] )
  end
  
  ##
  # Tests for a maximum number of lower case alpha characters
  #
  def test_maximum_lower_alphas( *params )
    params[0] ||= @test_params[current_method_name]
    maximum_test( /[a-z]/, params[0] )
  end
  
  ##
  # Tests for a minimum number of numeric characters
  #
  def test_minimum_numerals( *params )
    params[0] ||= @test_params[current_method_name]
    minimum_test( /[0-9]/, params[0] )
  end
  
  ##
  # Tests for a maximum number of numeric characters
  #
  def test_maximum_numerals( *params )
    params[0] ||= @test_params[current_method_name]
    maximum_test( /[0-9]/, params[0] )
  end
  
  ##
  # Tests for a minimum number of numeric characters
  #
  def test_minimum_non_alpha( *params )
    params[0] ||= @test_params[current_method_name]
    minimum_test( /[^A-Za-z]/, params[0] )
  end
  
  ##
  # Tests for a maximum number of numeric characters
  #
  def test_maximum_non_alpha( *params )
    params[0] ||= @test_params[current_method_name]
    maximum_test( /[^A-Za-z]/, params[0] )
  end
  
  ##
  # Tests for a minimum number of non-alphanumeric characters
  #
  def test_minimum_non_alphanumeric( *params )
    params[0] ||= @test_params[current_method_name]
    minimum_test( /[^A-Za-z0-9]/, params[0] )
  end
  
  ##
  # Tests for a maximum number of non-alphanumeric characters
  #
  def test_maximum_non_alphanumeric( *params )
    params[0] ||= @test_params[current_method_name]
    maximum_test( /[^A-Za-z0-9]/, params[0] )
  end
  
  ##
  # Get a default test parameters hash of the given level of security.  The 
  # default level is <tt>:medium_low</tt>.
  # 
  # Levels:
  # 
  # <tt>:low</tt>:          minimum 6 characters, at least 1 letter
  # <tt>:medium_low</tt>:   minimum 8 characters, at least 1 letter and 1 
  #                         non-alpha character (ie. number or symbol) <b>default</b>
  # <tt>:medium_high</tt>:  minimum 8 characters, at least 1 upper-case letter,
  #                         1 lower-case letter, and 1 non-alpha character (ie.
  #                         number or symbol)
  # <tt>:high</tt>:         minimum 8 characters, at least 1 upper-case letter,
  #                         1 lower-case letter, 1 numeral character, and 1 
  #                         symbol
  # 
  def default_test_params( level = :medium_low )
    case level
    when :low
      { :test_length => 6, 
        :test_minimum_alphas => 1 }
    when :medium_low
      { :test_length => 8, 
        :test_minimum_alphas => 1,
        :test_minimum_non_alpha => 1}
    when :medium_high
      { :test_length => 8, 
        :test_minimum_upper_alphas => 1,
        :test_minimum_lower_alphas => 1,
        :test_minimum_non_alpha => 1 }
    when :high
      { :test_length => 8, 
        :test_minimum_upper_alphas => 1,
        :test_minimum_lower_alphas => 1,
        :test_minimum_numerals => 1,
        :test_minimum_non_alphanumeric => 1}
    else
      raise "#{level.to_s} is not a valid level"
    end
  end
  
  ##
  # Tests the strength of a given password qualitativly and returns a numerical
  # strength.
  #
  # The algorithm is modified from 
  # http://phiras.wordpress.com/2007/04/08/password-strength-meter-a-jquery-plugin/
  # 
  # Examples:
  # 
  #   PasswordTests.qualitative_strength( '123456')       => 0
  #   PasswordTests.qualitative_strength( 'foo' )         => 0
  #   PasswordTests.qualitative_strength( 'fooo' )        => 2
  #   PasswordTests.qualitative_strength( 'foobar' )      => 12
  #   PasswordTests.qualitative_strength( '1fo0^*bar9' )  => 95
  #
  def self.qualitative_strength( password )
    return 0 if password.length < 4
    
    score = password.length * 4
    
    # repetitions
    reps = PasswordTests.repetitions( password )
    reps.each { |rep,times| score -= rep.size * 2 * times }
    
    # counts
    nums = password.scan( /\d/ ).size
    symbols = password.scan( /[^A-Za-z0-9]/ ).size
    lower_alphas = password.scan( /[a-z]/ ).size
    upper_alphas = password.scan( /[A-Z]/ ).size
    
    alphas = lower_alphas + upper_alphas
    
    score += 5   if nums >= 3
    score += 5   if symbols >= 2
    score += 15  if nums > 0 && symbols > 0
    score -= 10  if nums == 0 && symbols == 0
    score += 10  if lower_alphas > 0 && upper_alphas > 0
    score += 15  if nums > 0 && alphas > 0
    score += 15  if symbols > 0 && alphas > 0
    score -= 30  if symbols == 0 && alphas == 0
    
    return score if score > 0
    return 0
  end
  
  ##
  # Finds all character sequences that are repeated in the password
  # 
  # Example:
  # 
  #   PasswordTests.repetitions( 'foofoo') => {"foo" => 1, "f" => 1, "oo" => 1, "o" => 3}
  # 
  def self.repetitions( password, splits = [], reps = {} )
    splits = [password[0...(password.length/2)], 
              password[(password.length/2)...password.length]] if splits.empty?
    
    next_splits = []
    
    splits.each do |partial|
      r = password.scan(partial)
      reps[r[0]] = r.size-1 if r.size > 1 && (not reps.include?(r[0]))
      
      if partial.length > 1
        next_splits << partial[0...(partial.length/2)]
        next_splits << partial[(partial.length/2)...partial.length]
      end
    end
    
    repetitions( password, next_splits, reps ) unless next_splits.empty?
    
    return reps
  end
  
  ##
  # Calculates the entropy of the given password (in bits).
  #
  # Note: Technically, when using a deterministic (pseudo) random number 
  # generator, the entropy of ANY password will be the size of the set of 
  # integers the random function is picking from (eg. if you use rand(255) the  
  # entropy would be 8, but if you use rand(), the entropy would be 32).
  # 
  # This is a simplified implementation of the formula for entropy on page 4 
  # of RFC 4086 (http://www.ietf.org/rfc/rfc4086.txt).
  # 
  # This wikipedia has an explanation of password entropy:
  # http://en.wikipedia.org/wiki/Random_password_generator
  # 
  # Examples:
  # 
  #   Password.entropy('1')           => 3.32192809488736
  #   Password.entropy('123456')      => 19.9315685693242
  #   Password.entropy('foobar')      => 28.2026383088466
  #   Password.entropy('1fo0^*bar9')  => 61.0852445677817
  # 
  def self.entropy( password )
    n = 0
    n += 26 if password.scan( /[a-z]/ ).size > 0
    n += 26 if password.scan( /[A-Z]/ ).size > 0
    n += 10 if password.scan( /[0-9]/ ).size > 0
    n += 33 if password.scan( /[^A-Za-z0-9]/ ).size > 0
    
    return password.length * (Math.log10(n) / Math.log10(2))
  end
  protected
  
  ##
  # Execute a minimum test
  #
  def minimum_test( pattern, minimum )
    @password.scan(pattern).size >= minimum
  end
  
  ##
  # Execute a maximum test
  #
  def maximum_test( pattern, maximum )
    @password.scan(pattern).size <= maximum
  end

  ##
  # Returns the method name of the method that calls current_method_name
  #
  # Example:
  # 
  #   def test
  #     current_method_name
  #   end
  #
  #   irb(main):063:0> test
  #   => :test
  #
  def current_method_name
    caller[0].match(/`([^']+)/).captures[0].to_sym
  end
end

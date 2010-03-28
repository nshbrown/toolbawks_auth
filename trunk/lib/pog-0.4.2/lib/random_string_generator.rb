##
# = random_string_generator.rb
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
require File.join( File.dirname(__FILE__), 'character_ranges.rb' )

##
# == RandomStringGenerator Class
#
# RandomStringGenerator provides the functionality to generate random Strings.
# It could be called RandomPasswordGenerator.
#
#
# === Generating a Random Password
# 
# This is how to generate a random String with the default settings (see
# RandomStringGenerator.new for list of options)
# 
#   rsg = RandomStringGenerator.new
#   str = rsg.generate => #<String>
# 
# This will generate a random String of length 10, with no duplicate 
# characters, and not using an uppercase characters.
# 
#   rsg = RandomStringGenerator.new( 10, :no_duplicates => true, :upper_alphas => false )
#   str = rsg.generate => #<String>
# 
# 
# === Changing the length and options between generations
# 
#   rsg = RandomStringGenerator.new
#   str = rsg.generate
# 
# Now change the options and length and call generate
# 
#   rsg.set_options( :special => 'qwerty', :no_duplicates => true)
#   rsg.length = 6
#   str = rsg.generate
# 
# 
# === Generate a WEP key
# 
# This will generate a 64 bit WEP key in hexidecimal format
# 
#   wep_64b_hex = RandomStringGenerator.generate_wep( 64 )
# 
# This will generate a 128 bit WEP key in ASCII format.  (Note that ASCII WEP 
# keys are not as secure as hexidecimal keys)
# 
#   wep_128b_ascii = RandomStringGenerator.generate_wep( 128, :ascii )
# 
# 
# === Shuffle a String
#
# You can shuffle a string inplace (destructively) or you can shuffle the 
# String into a new one.
# 
# Inplace:
# 
#   str = 'foobar'
#   RandomStringGenerator.shuffle_string! str
# 
# +str+ is now shuffled.
# 
# New String:
# 
#   str = 'foobar'
#   new_str = RandomStringGenerator.shuffle_string str
# 
# +str+ is not touched
# +new_str+ is a shuffled version of +str+
# 
class RandomStringGenerator
  include CharacterRanges
  
  ##
  # Initializes a new random string generator.
  #
  # +len+ is the length of the string you wish to have generated.  Default is 8.
  #
  # Options:
  #
  # <tt>:no_duplicates</tt>::       no duplicate characters, default is false
  # <tt>:lower_alphas</tt>::        include lower alpha characters, default is true
  # <tt>:upper_alphas</tt>::        include upper alpha characters, default is true
  # <tt>:numerals</tt>::            include numeral characters, default is true
  # <tt>:symbols</tt>::             include symbol characters, default is false
  # <tt>:single_quotes</tt>::       include single quote characters, default is false
  # <tt>:double_quotes</tt>::       include double quote characters, default is false
  # <tt>:backtick</tt>::            include tick characters, default is false
  # <tt>:special</tt>::             use a special string or array of ranges, overrides all other inclusion options
  #
  def initialize( len = 8, options = {} )
    @length = len
    @options = { :lower_alphas => true,
      :upper_alphas => true,
      :numerals     => true,
      :no_duplicates=> false}.merge options
    
  end
  
  ##
  # Get the length of the password to be generated.
  #
  def length
    @length
  end
  
  ##
  # Set the length of the password to be generated.
  #
  def length=( len )
    @length = len
  end
  
  ##
  # Get the options hash.
  #
  # See RandomStringGenerator.new for the list of options.
  #
  def options
    return @options
  end
  
  ##
  # Set the given options in 
  #
  # See RandomStringGenerator.new for the list of options.
  #
  def set_option( opts = {} )
    @options.merge!( opts )
  end
  
  ##
  # Generate a password.
  # 
  def generate
    set_characters_array
    
    # safety check for no_duplicates running out of characters
    if @options[:no_duplicates] && @characters.length < @length
      raise RuntimeError, "Too few options to have no duplicates."
    end
    shuffle_characters_array
    
    # generate the password
    p = String.new
    for i in 0...@length
      p << rand_char( @options[:noduplicates] )
    end
    return RandomStringGenerator.shuffle_string!(p)
  end

  ##
  # Get a random character from the characters array.  Set the parameter to 
  # +true+ to remove the character from the list after it's been returned. 
  #
  def rand_char( delete_after_get = false )
    i = rand_index
    end_i = i + @characters.length
    
    until @characters[ i % @characters.length ] > 0 do # Walk until you find a non-0 character
      raise "No more characters." if i == end_i
      i += 1
    end
    c = @characters[ i % @characters.length ].chr # c is now the character we will return
    @characters[ i % @characters.length ] = 0 if delete_after_get # set the character to 0 (indicating deletedness)
    return c
  end
  
  ##
  # Shuffles the given string (destructively aka. inplace)
  #
  def self.shuffle_string!( str )
    scramblers = Array.new(8)
    for i in 0...(str.length/2)
      scrambler_1 = rand(0xffffffff)
      scrambler_2 = rand(0xffffffff)
      for j in 0...4
        scramblers[j] = ((scrambler_1 & (0xff<<j*8)) >> j*8) % str.length
      end
      for j in 4...8 
        scramblers[j] = ((scrambler_2 & (0xff<<(j-4)*8)) >> (j-4)*8) % str.length
        # offset the wrap around to the end of the string
        scramblers[j] = (scramblers[j] + (0xff%str.length)) % str.length
      end
      
      # do the scrambling
      t = str[scramblers[0]]
      7.times { |j| str[scramblers[j]] = str[scramblers[j+1]] }
      str[scramblers[7]] = t
    end
    return str
  end
  
  ##
  # Returns a shuffled version of the given string.
  #
  def self.shuffle_string( str )
    RandomStringGenerator.shuffle_string!( str.dup )
  end
  
  ##
  # Scramble the characters array
  # 
  def shuffle_characters_array
    RandomStringGenerator.shuffle_string!( @characters )
  end
  
  ##
  # Set the characters array to the set that we can use to generate a new 
  # password.
  #
  def set_characters_array
    if @options.has_key? :special # set to special if it's there
      set_characters_from_special( @options[:special] )
    else # set by the given ranges
      ranges = Array.new
      @options.each do |opt, val| # run through options
        unless opt == :length || opt == :no_duplicates || val == false 
          ranges << self.send("range_#{opt.to_s}")
        end
      end
      set_characters_from_ranges ranges.flatten
    end
  end
  
  
  ##
  # Generates a WEP key
  #
  # +bits+:     The number of bits for the encryption policy (ie. 64, 128, 152, 256)
  # +output+::  Either <tt>:hex</tt> or <tt>:ascii</tt> (hex is more secure)
  #
  def self.generate_wep( bits, output = :hex )
    raise "Not a valid number of bits for a WEP key." unless [64,128,152,256].include? bits
    
    case output
    when :hex
      rsg = RandomStringGenerator.new((bits-24)/8, :special => [0..0xff])
      key = rsg.generate
      return key.unpack("H#{key.length*2}").at(0) if output == :hex
    when :ascii
      rsg = RandomStringGenerator.new((bits-24)/8, :special => [0x20..0x7e])
      key = rsg.generate
      return key
    else
      raise "Invalid output type."
    end
  end
  
  protected

  ##
  # Get a random index of the characters array
  #
  def rand_index
    j = rand(@characters.length**4)
    i = 0
    for k in 0...4
      i += (j & (0xff<<k*8)) >> k*8
    end
    i %= @characters.length
  end
  
  ##
  # Set the characters array using the :special options variable to the set we
  # can use to generate a new pasword.
  #
  def set_characters_from_special( special )
    if special.is_a? Array # check that each value of the array is a range
      special.each do |r|
        raise ArgumentError, ":special must either be a String or an Array of Ranges." unless r.is_a? Range
      end
      set_characters_from_ranges special
    elsif special.is_a? String
      @characters = special
    else # must either be a string or array of ranges
      raise ArgumentError, ":special must either be a String or an Array of Ranges."
    end
  end
  
  ##
  # Set the characters array by the @ranges variable to the set that we can 
  # use to generate a new password.
  # 
  def set_characters_from_ranges( ranges )
    @characters = String.new
    ranges.each do |r|
      for i in r
        @characters << i.chr
      end
    end
    @characters
  end
end
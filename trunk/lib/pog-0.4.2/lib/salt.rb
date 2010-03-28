##
# = salt.rb
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
# == Salt Class
#
# Salt encapsulates a password's salt and provides functionality for password 
# salting and random salt generation.
#
#
# === What is a "password salt"?
# 
# A "password salt" is a string that is added to a password string to obscure
# the password when it is hashed to keep the password hash from being cracked.
#
# See http://en.wikipedia.org/wiki/Salt_(cryptography)
#
#
# === Setting up a new Salt
# 
# This generates a new, random salt, with end placement
#
#   s = Salt.new 
# 
# This creates the salt 'foobar', with split placement.
#
#   s = Salt.new('foobar')
# 
# This generates a new, random salt of length 9, with end placement
#
#   s = Salt.new( :new, :end, :length => 9)
# or
#   s = Salt.new( Salt.generate( 8 ) )
#
#
# === Salting a password
# 
# This will salt the password 'foobar'
#
#   s = s.salt('foobar')
#
#
# === What is salt placement?
# 
# "salt placement" is where the salt will go in the password.  For example, 
# "beginning" salt placement would prepend the salt to the password prior to
# hashing, and "split" salt placement would prepend the first half and
# append the second half.
#
class Salt
  attr_accessor :string, :placement
  
  ##
  # Initializes a new Salt instance with the given +string+ and +placement+
  # 
  # See Salt.placement= for +placement+ options
  # 
  # Options:
  # 
  # <tt>:length</tt>:     the length for a new salt. (default is 8)
  #
  def initialize( string = :new, placement = :end, options = {} )
    @placement  = placement.to_sym
    @string     = (string == :new ? 
                   Salt.generate_str(options[:length] || 8) : string)
  end
  
  ##
  # Get the salt string
  #
  def string
    @string
  end
  
  ##
  # Set the salt string
  #
  def string=( new_string )
    @string = new_string
  end
  
  ##
  # Get the salt's placement
  #
  def placement
    @placement
  end
  
  ##
  # Set the salt's placement
  # 
  # Valid placements: <tt>:end</tt> (default), <tt>:beginning</tt>, <tt>:split</tt>
  #
  def placement=( new_placement )
    @placement = new_placement.to_sym
  end
  
  ##
  # Returns the given password, salted.
  #
  def salt_password( password )
    case placement.to_sym
    when :end
      password.to_s + string
    when :beginning
      string + password.to_s
    when :split
      string[0...(string.length/2).floor] + password.to_s + string[(string.length/2).floor...string.length]
    else
      raise RuntimeError, "#{placement.to_s} is an invalid salt placement."
    end
  end
  
  ##
  # Returns the salt string.
  # 
  # Same as calling Salt#string
  # 
  def to_s
    string.to_s
  end
  
  ##
  # Generate a salt string of the given length (default is 8).
  # 
  def self.generate_str(length = 8)
    RandomStringGenerator.new( length, { :lower_alphas => true,
                                         :upper_alphas => true,
                                         :numerals     => true,
                                         :symbols      => true }).generate
  end
end
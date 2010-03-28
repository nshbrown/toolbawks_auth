##
# = password.rb
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
require 'digest/md5'
require 'digest/sha1'
require 'digest/sha2'

##
# == Password Class
#
# Password encapsulates a password and provides functionality for hashing, 
# hash-based authentication, and random password generation.
#  
# 
# === Setting up a new Password object
#
# This will create a new Password object using no salt and the default, SHA256
# digest.
# 
#   p = Password.new( 'foobar' )
#
# This will create a new Password object using a new, random salt and the 
# SHA512 digest.
# 
#   p = Password.new( 'foobar', Salt.new, :sha512 )
#
# This will create a new, random password (using default random generation 
# options -- see Password.new) using no salt, and the default, SHA256 
# digest.
# 
#   p = Password.new( :new )
#
# This will create a new, random password of length 10 (and using default 
# random generation options -- see Password.new) using no salt, and the 
# MD5 digest.
# 
#   p = Password.new( :new, nil, :md5, :length => 10 )
# 
# 
# === Getting the hash 
# 
# This hash will give the hash in binary format.
# 
#   hash = p.hash
# 
# This hash will give the hash in hexidecimal format.
# 
#   hash = p.hash( :hex )
# 
# 
# === Authenticating a password
#
# This will authenticate the Password +p+ using String +auth_hash_data+ that 
# was gotten from a database.
# 
#   authenticated = p.authenticate( auth_hash_data ) => true/false
# 
# 
# === Generating a random password
#
# See Password.new for all options.  The same options may be passed to 
# the constructor's +generation_options+ parameter with the password set as 
# <tt>:new</tt> to generate a new random password.
#
#   p = Password.new( :new, nil, :sha256, :length => 8, 
#                                         :no_duplicates => true )
# 
# 
# === Changing the +salt+ and +digest+
#
# When you change/set the +password+, +salt+, or +digest+, you will automatically regenerate 
# the +hash+ that is stored within the Password instance.
#
#   p.salt = Salt.new
#   p.digest = :sha1
# 
class Password
  
  ##
  # Initialize a new Password object
  #
  # When +password+ is a String, it is set as the password.
  # 
  # When +password+ is <tt>:new</tt>; a new, random password is generated via 
  # <tt>RandomStringGenerator</tt> with the given +generation_options+.
  #
  # +salt+:               see Password.salt=
  # +digest+:             see Password.digest=
  #
  # Generation Options
  # 
  # <tt>:length</tt>::              length of the password, default is 8
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
  def initialize( password, salt = nil, digest = :sha256, generation_options = {} )
    if password == :new
      len = generation_options.delete(:length)
      @password = RandomStringGenerator.new( len || 8, generation_options ).generate
    else
      @password = password
    end
    @salt = salt
    @digest = digest
    rehash
  end
  
  ##
  # Get the password
  #
  def password
    @password
  end
  
  ##
  # Set the password (and regenerate the hash)
  #
  def password=( new_password )
    @password = new_password.to_s
    rehash
    @password
  end
  
  ##
  # Get the salt
  #
  def salt
    @salt
  end
  
  ##
  # Set the salt (and regenerate the hash)
  #
  # +new_salt+ may be either a Salt or String instance
  #
  def salt=( new_salt )
    @salt = (new_salt.is_a?(String) ? Salt.new(new_salt) : new_salt)
    rehash
    @salt
  end
  
  ##
  # Get the digest
  #
  def digest
    @digest
  end
  
  ##
  # Set the digest (and regenerate the hash)
  #
  # +new_digests+ must be one of: <tt>:md5</tt>, <tt>:sha1</tt>, 
  # <tt>:sha256</tt>, <tt>:sha384</tt>, <tt>:sha512</tt>
  #
  def digest=( new_digest )
    @digest = new_digest.to_sym
    rehash
    @digest
  end
  
  ##
  # Gets the hash, or generates one if one hasn't already been generated, and 
  # stores it for future use.
  #
  # +format+ must be one of: <tt>:binary</tt> (default), <tt>:hex</tt>, 
  # <tt>:base64</tt>
  # 
  def hash( format = :binary )
    case format.to_sym
    when :binary, :bin
      return @hash
    when :hex, :hexidecimal
      return bin_to_hex(@hash)
    when :base64
      return bin_to_b64(@hash)
    else
      raise ArgumentError, "#{format.to_s} is an invalid format."
    end
  end
  
  ##
  # Rehash the password.
  #
  # If you
  #
  def rehash
    # Do the salting
    salted = generate_salted( password, salt )
    
    # Do the hashing
    @hash = generate_hash( salted, digest )
  end
  
  ##
  # Returns the password string.
  # 
  # Same as calling Password.password
  # 
  def to_s
    password
  end

  ##
  # Attempts to authenticate the given password against the given hash.  The 
  # salt used to create the given hash MUST match the salt of this Password 
  # object.  The digest and format of the given hash are automatically 
  # detected.
  #
  def authenticate( auth_hash_data )
    f, d = detect_type( auth_hash_data )

    h = generate_hash( generate_salted(password, salt), d )
    
    # convert h to proper format
    case f
    when :hex
      h = bin_to_hex h
    when :base64
      h = bin_to_b64 h
    end
    
    auth_hash_data == h
  end
  
  protected
  
  ##
  # Detects the type of the hash +h+
  # 
  # Returns 2 variables: format, digest
  #
  # Example:
  #
  #   format, digest = detect_type( hash )
  def detect_type( h )
    # detect format
    if h == h.match(/[a-f0-9]*/)[0] # hex
      f = :hex
    elsif h.gsub(/\s+/, '') == 
      h.gsub(/\s+/, '').match(/[A-Za-z0-9\+\/\=]*/)[0] # base64
      f = :base64
    else
      f = :binary
    end
    
    # convert to binary
    case f
    when :hex
      h = hex_to_bin h
    when :base64
      h = b64_to_bin h
    end
    
    # detect digest
    case h.length
    when 16
      d = :md5
    when 20
      d = :sha1
    when 32
      d = :sha256
    when 48
      d = :sha384
    when 64
      d = :sha512
    else
      raise "Invalid hash, digest is unknown."
    end
    
    return f, d
  end
  
  ##
  # Generates a hash of the given string +str+ and digest +d+
  #
  def generate_hash( str, d )
    case d.to_sym
    when :sha256
      return Digest::SHA256.digest(str)
    when :sha384
      return Digest::SHA384.digest(str)
    when :sha512
      return Digest::SHA512.digest(str)
    when :sha1
      return Digest::SHA1.digest(str)
    when :md5
      return Digest::MD5.digest(str)
    else
      raise RuntimeError, "#{d.to_s} is an invalid digest."
    end
  end
  
  ##
  # Generates the salted string for hashing from password +p+ and salt +s+
  #
  def generate_salted( p, s = nil)
    s.nil? ? p.to_s : s.salt_password(p)
  end
  
  ##
  # Converts a binary string +str+ to hexidecimal
  #
  def bin_to_hex( str )
    str.unpack("H#{str.length*2}").at(0)
  end
  
  ##
  # Converts a hexidecimal string +str+ to binary
  #
  def hex_to_bin( str )
    [str].pack("H#{str.length}")
  end
  
  ##
  # Converts a binary string +str+ to base 64
  #
  def bin_to_b64( str )
    [str].pack('m').gsub(/\s+/, '')
  end
  
  ##
  # Converts a base64 string +str+ to binary
  #
  def b64_to_bin( str )
    str.unpack("m").at(0)
  end
end



##
# = character_ranges.rb
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
# == CharacterRanges Module
#
# CharacterRanges provides preset ranges for sets of ASCII characters for 
# random password generation.
#
# === List of Ranges
# +upper_alphas+::          0x41..0x5a - A..Z
# +lower_alphas+::          0x61..0x7a - a..z
# +numerals+::              0x30..0x30 - 0..9
# <tt>symbols_1</tt>::      0x21..0x21 - !
# <tt>symbols_2</tt>::      0x23..0x26 - #..&
# <tt>symbols_3</tt>::      0x28..0x2f - (../
# <tt>symbols_4</tt>::      0x3a..0x40 - :..@
# <tt>symbols_5</tt>::      0x5b..0x5f - [.._
# <tt>symbols_6</tt>::      0x7b..0x7e - {..~
# +single_quotes+::         0x27..0x27 - '
# +double_quotes+::         0x22..0x22 - "
# +backtick+::              0x60..0x60 - `
# 

module CharacterRanges
  
  ##
  # Get a specific range.  See "List of Ranges" above.
  # 
  # Example:
  #
  #  CharacterRanges.range( :upper_alphas ) => 0x41..0x5a
  #
  def range( sym )
    case sym.to_sym
    when :upper_alphas
      0x41..0x5a
    when :lower_alphas
      0x61..0x7a
    when :numerals
      0x30..0x39
    when :symbols_1
      0x21..0x21
    when :symbols_2
      0x23..0x26
    when :symbols_3
      0x28..0x2f
    when :symbols_4
      0x3a..0x40
    when :symbols_5
      0x5b..0x5f
    when :symbols_6
      0x7b..0x7e
    when :single_quotes
      0x27..0x27
    when :double_quotes
      0x22..0x22
    when :backtick
      0x60..0x60
    else
      raise ArgumentError, "#{sym.to_s} is an invalid range."
    end
  end
  
  ##
  # The upper case alpha ASCII ranges as a single-member Array.
  # 
  # (0x41..0x5a - A..Z)
  #
  def range_upper_alphas
    [ range(:upper_alphas) ]
  end
  
  ##
  # The lower case alpha ASCII range as a single-member Array.
  # 
  # (0x61..0x7a - a..z)
  #
  def range_lower_alphas
    [ range(:lower_alphas) ]
  end
  
  ##
  # The numeral ASCII ranges as a single-member Array.
  # 
  # 0x30..0x30 - 0..9
  #
  def range_numerals
    [ range(:numerals) ]
  end
  
  ##
  # The symbols ASCII ranges as a 6-member Array.
  #
  # <tt>symbols_1</tt>::      0x21..0x21 - !
  # <tt>symbols_2</tt>::      0x23..0x26 - #..&
  # <tt>symbols_3</tt>::      0x28..0x2f - (../
  # <tt>symbols_4</tt>::      0x3a..0x40 - :..@
  # <tt>symbols_5</tt>::      0x5b..0x5f - [.._
  # <tt>symbols_6</tt>::      0x7b..0x7e - {..~
  #
  def range_symbols
    [ range(:symbols_1), 
      range(:symbols_2), 
      range(:symbols_3), 
      range(:symbols_4), 
      range(:symbols_5), 
      range(:symbols_6) ]
  end
  
  ##
  # All the ranges except the quote ranges (ie single, double, and backtick).
  #
  def range_all_except_quotes
    [ range(:upper_alphas), 
      range(:lower_alphas), 
      range(:numerals), 
      range(:symbols_1), 
      range(:symbols_2), 
      range(:symbols_3), 
      range(:symbols_4), 
      range(:symbols_5), 
      range(:symbols_6) ]
  end
  
  ##
  # The single quotes ASCII ranges as a single-member Array.
  # 
  # (0x27..0x27 - ')
  #
  def range_single_quotes
    [ range(:single_quotes) ]
  end
  
  ##
  # The double quotes ASCII ranges as a single-member Array.
  # 
  # (0x22..0x22 - ")
  #
  def range_double_quotes
    [ range(:double_quotes) ]
  end
  
  ##
  # The backtick ASCII ranges as a single-member Array.
  # 
  # (0x60..0x60 - `)
  # 
  def range_backtick
    [ range(:backtick) ]
  end
  
  ##
  # All the ranges except the quote ranges (ie single, double, and backtick).
  #
  def range_all
    [ range(:upper_alphas), 
      range(:lower_alphas), 
      range(:numerals), 
      range(:symbols_1), 
      range(:symbols_2), 
      range(:symbols_3), 
      range(:symbols_4), 
      range(:symbols_5), 
      range(:symbols_6),
      range(:single_quotes),
      range(:double_quotes),
      range(:backtick) ]
  end
end
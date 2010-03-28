# Copyright (c) 2007 Nathaniel Brown
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'digest/sha1'

class ToolbawksUser < ActiveRecord::Base
  validates_presence_of :salt, :message => 'An internal error has occurred'
  validates_length_of :salt, :is => 8, :message => 'An internal error has occurred'

  validates_format_of :email, :with => /^\S+\@(\[?)[a-zA-Z0-9\-\.]+\.([a-zA-Z]{2,4}|[0-9]{1,4})(\]?)$/ix, :message => 'Email is invalid'
  validates_uniqueness_of :email, :message => 'Email is already registered. <a href="/forgot_password">Forgot your password?</a>'
  
  validates_length_of :password, :minimum => 4, :message => 'Password is too week'
  validates_confirmation_of :password, :message => 'Passwords do not match'
  
  before_validation_on_create :create_salt
  before_save :password_encrypt
  
  # This should be dynamic, and only enabled if ToolbawksAuthProfile has been installed. Fix later
  has_many :profiles, :class_name => 'ToolbawksProfile', :dependent => :destroy, :foreign_key => 'toolbawks_user_id'
  
  has_one :default_profile, :class_name => 'ToolbawksProfile', :foreign_key => 'toolbawks_user_id', :conditions => ['is_default = ?', true]
  
  def password_encrypt
    if self.new_record? || (self.password != ToolbawksUser.find(self.id).password)
      logger.info 'ToolbawksUser.password_encrypt -> encrypting password : ' + self.password
      self.password = Password.new(self.password, Salt.new(self.salt)).hash(:hex)
    else
      logger.info 'ToolbawksUser.password_encrypt -> password already encrypted or hasn\'t changed : ' + self.password
    end
  end
  
  def create_salt
    if !self.salt || self.salt == ''
      self.salt = Salt.new(:new, :end, :length => 8).to_s
    end
  end
  
  def authenticate(password_check)
    logger.info 'ToolbawksUser.authenticate -> plain text: ' + password_check + ', salt : ' + self.salt + ', password_hash : ' + self.password + ', re-generated hash: ' + Password.new(password_check, Salt.new(self.salt)).hash(:hex)
    valid_password = Password.new(password_check, Salt.new(self.salt)).authenticate(self.password)
    
    if !valid_password
      errors.add :password, 'Invalid password'
    end
    
    return valid_password
  end
  
  def generate_token
    Digest::SHA1.hexdigest("#{self.id}-#{self.salt}-#{self.password}-#{Time.now.to_i}")[0..39]
  end
end
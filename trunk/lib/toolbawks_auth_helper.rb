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

module ToolbawksAuthHelper
	def login_required
  end

  def check_authorization
    access_denied = false
    
    # Verify that this session has proper access to this area
    # They may not be logged in (anonymous)
    
    if access_denied
      redirect_to '/access_denied' and return false
    end
  end
  
  def ensure_logged_in
	  # Default check to see if this area requires you to be logged in
	  if !session[:toolbawks_auth][:user]
      redirect_to '/login' and return false
	  end
  end
  
  def force_login
    if !logged_in?
      logger.info 'ToolbawksAuthHelper.force_login -> !logged_in?'
      set_referral(request.request_uri)
      redirect_to '/login' and return false
    else
      logger.info 'ToolbawksAuthHelper.force_login -> logged_in already'
      return true
    end
  end
  
  def set_referral(ref)
    session[:toolbawks_auth_ref] = ref if !ref.include?('login') && !ref.include?('register')
  end

  def get_referral
    session[:toolbawks_auth_ref]
  end

  def set_current_user(user)
    session[:toolbawks_auth_user] = user
  end
  
  alias_method :set_user, :set_current_user

  def current_user
    session[:toolbawks_auth_user]
  end
  
  alias_method :get_user, :current_user
  
  def logged_in?
    if session[:toolbawks_auth_user] != nil
      return true
    else
      return false
    end
  end

  alias_method :user?, :logged_in?
  
  def refresh_user_from_cookie
    return if logged_in?
    
    if !cookies[:login].nil?
      user = ToolbawksUser.find_by_login_token(cookies[:login])
      
      if !user.nil?
        set_current_user(user)
      else
        logger.info "ToolbawksAuthHelper.refresh_user_from_cookie -> User not found by login token. #{cookies[:login]}"
        cookies[:login] = nil
      end
    end
  end
end
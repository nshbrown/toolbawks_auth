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

class Toolbawks::AuthController < Toolbawks::BaseController
	after_filter :delete_login_cookie, :only => [ :logout ]
  around_filter :action_mailer_default_url, :only => [ :forgot_password ]

  def login
    if logged_in?
      redirect_to '/'
    end
    
    set_referral(params[:ref]) if params[:ref]

    if request.post?
      if params[:account][:existing] == 'no'
        redirect_to '/register?e=' + params[:toolbawks_user][:email] and return
      else
        @toolbawks_user = ToolbawksUser.find_by_email(params[:toolbawks_user][:email])
      
        if !@toolbawks_user
          @toolbawks_user = ToolbawksUser.new(params[:toolbawks_user])
          @toolbawks_user.valid?
        elsif @toolbawks_user.authenticate(params[:toolbawks_user][:password])
          # Redirect back to "ref" url once they have logged in
          set_user(@toolbawks_user)
          
          if params[:remember_me][:enabled] == '1'
            set_login_cookie
          end
          
          logger.info "Toolbawks::AuthController.login -> session[:toolbawks_auth_ref] : #{session[:toolbawks_auth_ref]}"
          
          if get_referral && get_referral != request.request_uri
            redirect_to get_referral and return
          else
            redirect_to '/' and return
          end
        else
          @errors = ['Password is invalid']
        end
      end
    end
  end
  
  def logout
    set_user(nil) if logged_in?
    
    redirect_to '/' and return
  end
  
  def register
    params[:toolbawks_user] ||= {}
    params[:toolbawks_user][:email] = params[:e] if params[:e]
    
    # no need to register if they are logged in
    redirect_to '/' and return if logged_in?
    
    # Redirect back to "ref" url once they have logged in
    set_referral(params[:ref]) if params[:ref]
    
    @toolbawks_user = ToolbawksUser.new(params[:toolbawks_user])

    if request.post?
      @toolbawks_user = ToolbawksUser.new(params[:toolbawks_user])
      @toolbawks_user.profiles.build(params[:toolbawks_profile])
      
      if @toolbawks_user.save
        logger.info 'Toolbawks::AuthController.register -> register : success'
        # user has saved, profile has been created
        set_user(@toolbawks_user)
        
        # continue them to where they need to go
        if get_referral && get_referral != url_for(:controller => params[:controller], :action => params[:action])
          redirect_to(get_referral) and return
        else
          redirect_to '/' and return
        end
      else
        logger.info 'Toolbawks::AuthController.register -> register : failure, user_errors : ' + @toolbawks_user.errors.inspect
        # errors
      end
    end
  end
  
  def password_strength
  end
  
  def forgot_password
    if request.post?
      @toolbawks_user = ToolbawksUser.find_by_email(params[:toolbawks_user][:email])
    
      if @toolbawks_user
        password_token = @toolbawks_user.generate_token
        logger.info 'ToolbawksAuth.change_password -> password_token : ' + password_token

        @toolbawks_user.update_attribute(:password_token, password_token)
        
        ToolbawksAuthNotifier.deliver_forgot_password(@toolbawks_user, password_token)

        redirect_to :controller => 'toolbawks/auth', :action => 'forgot_password_sent', :email => @toolbawks_user.email and return
        # Send them an email with a encrypted url that they can visit to generate a new password
      else
        @toolbawks_user = ToolbawksUser.new(params[:toolbawks_user])
        @toolbawks_user.valid?
        @toolbawks_user.errors.add(:email, 'Email not found')
      end
    end
  end
  
  def forgot_password_sent
  end
  
  def reset_password
    token = params[:token]
    
    redirect_to :controller => 'toolbawks/auth', :action => 'forgot_password' and return if !token

    if !logged_in? && token && token.length == 40
      @toolbawks_user = ToolbawksUser.find_by_password_token(token)
      
      if !@toolbawks_user.nil?
        set_current_user(@toolbawks_user)
      else
        logger.warning "Toolbawks::AuthController.reset_password -> User not found by token. #{token}"
        flash[:error] = 'The forgot password token has expired. Please try again.'
        redirect_to :controller => 'toolbawks/auth', :action => 'forgot_password' and return
      end
    end
    
    if logged_in? && request.post?
      # New password is being set
      @toolbawks_user = current_user
      @toolbawks_user.update_attributes(:password_token => nil, :password => params[:toolbawks_user][:password], :password_confirmation => params[:toolbawks_user][:password_confirmation])
      if @toolbawks_user.valid?
        flash[:notice] = 'Password has been updated'
        redirect_to '/' and return
      end
    end
  end
  
  def access_denied
    # User is registered, but doesn't have the permissions to see the page they came from
    # Redirect back to "ref" url once they have logged in
    params[:ref]
  end

  protected

  def set_login_cookie
    logger.info 'ToolbawksAuth.set_login_cookie'
    
    if logged_in?
      logger.info 'ToolbawksAuth.set_login_cookie -> logged in'
      
      login_token = current_user.generate_token
      logger.info 'ToolbawksAuth.set_login_cookie -> login_token : ' + login_token
      
      current_user.update_attribute(:login_token, login_token)
      
      cookies[:login] = { 
        :value => login_token, 
        :expires => Time.now.next_year
      }
    else
      logger.info 'ToolbawksAuth.set_login_cookie -> not logged in'
    end
  end

  def delete_login_cookie
    cookies.delete :login
  end
end
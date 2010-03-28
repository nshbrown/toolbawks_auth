/*
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
*/

Toolbawks.auth.Interface = function() {
  return {
    init : function() {
      Toolbawks.log('Toolbawks.auth.Interface.init');
      
      var toolbawks_user_password = Ext.get('toolbawks_user_password');
      if (toolbawks_user_password) {
        var toolbawks_user_email = Ext.get('toolbawks_user_email');
        var toolbawks_user_password = Ext.get('toolbawks_user_password');

        // Assign the width to the slider
        var toolbawks_user_password_strength_slider = Ext.get('toolbawks_user_password_strength_slider');
        
        // Attach the events to the password field
        if (toolbawks_user_password_strength_slider) {
          var toolbawks_user_password_strength_slider_handle = Ext.get('toolbawks_user_password_strength_slider_handle');
          
          var password_strength_slider_options = {
            slider : toolbawks_user_password_strength_slider,
            slider_width : toolbawks_user_password_strength_slider.getWidth(),
            slider_handle : toolbawks_user_password_strength_slider_handle,
            slider_handle_width : toolbawks_user_password_strength_slider_handle.getWidth(),
            email_input : toolbawks_user_email,
            password_input : toolbawks_user_password
          };

          toolbawks_user_password.on('keyup', function() { Toolbawks.auth.Interface.register_password_strength_slider(password_strength_slider_options); });
          // Run the update immediately on load in case there is data in the field already
          Toolbawks.auth.Interface.register_password_strength_slider(password_strength_slider_options);
        }
        
        toolbawks_user_password.on('blur', Toolbawks.auth.Interface.validate_password);
      }
    },
    
    register_password_strength_slider : function(options) {
      Toolbawks.auth.Interface.update_password_strength_slider(options);
    },
    
    update_password_strength_slider : function(options) {
      var password = options.password_input.getValue();
      var email = (options.email_input ? options.email_input.getValue() : false);

      var strength = Toolbawks.auth.Password.strength(password, email);
      var strength_ratio = (strength / Toolbawks.auth.Password.strength_limit);
      
      var new_slider_handle_left_position = Math.round(strength_ratio * options.slider_width) - Math.round(options.slider_handle_width / 2);
      
      options.slider_handle.setLeft(new_slider_handle_left_position);
    },
    
    validate_password : function(event, input) {
    }
  };
}();

Ext.onReady(Toolbawks.auth.Interface.init, Toolbawks.auth.Interface, true);
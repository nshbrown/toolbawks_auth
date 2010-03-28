/*
# Copyright (c) 2007 Firas Kassem
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

/*
    * If the password matches the username then BadPassword
    * If the password is less than 4 characters then TooShortPassword
    * Score += password length * 4
    * Score -= repeated characters in the password ( 1 char repetition )
    * Score -= repeated characters in the password ( 2 char repetition )
    * Score -= repeated characters in the password ( 3 char repetition )
    * Score -= repeated characters in the password ( 4 char repetition )
    * If the password has 3 numbers then score += 5
    * If the password has 2 special characters then score += 5
    * If the password has upper and lower character then score += 10
    * If the password has numbers and characters then score += 15
    * If the password has numbers and special characters then score += 15
    * If the password has special characters and characters then score += 15
    * If the password is only characters then score -= 10
    * If the password is only numbers then score -= 10

    * If score > 100 then score = 100

    * If 0 < score < 34 then Weak Password
    * If 34 < score < 68 then Decent Password
    * If 68 < score < 100 then Strong Password

*/

Toolbawks.auth.Password = function() {
  return {
    strength_limit : 125,
    
    // Author: Firas Kassem  phiras.wordpress.com || phiras at gmail {dot} com
    // for more information : http://phiras.wordpress.com/2007/04/08/password-strength-meter-a-jquery-plugin/
    strength : function(password, username) {
      // If not username is passed, mark it definitively as such
      if (username == undefined || !username || username == '') {
        username = false;
      }
      
      // default the strength to zero
      var score = 0;

      // Zero score when the password is shorter than 4 characters
      if (password.length < 4 ) { 
        return score;
      }

      // Zero score when the password equals the username
      if (username && password.toLowerCase() == username.toLowerCase()) {
        return score;
      }

      // Password length
      score += password.length * 4; // +16 to * POINTS
      
      // Add points for unique characters by going through the password and search for repetitions of various lengths.
      score += ( Toolbawks.auth.Password.check_repetition(1, password).length - password.length ) * 1;
      score += ( Toolbawks.auth.Password.check_repetition(2, password).length - password.length ) * 1;
      score += ( Toolbawks.auth.Password.check_repetition(3, password).length - password.length ) * 1;
      score += ( Toolbawks.auth.Password.check_repetition(4, password).length - password.length ) * 1;

      //// BELOW - +65 POINTS MAX
      //// BELOW - -10 POINTS MAX
      
      //password has 3 numbers
      if (password.match(/(.*[0-9].*[0-9].*[0-9])/)) {
        score += 5;
      }

      //password has 2 sybols
      if (password.match(/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/)) {
        score += 5;
      }

      //password has Upper and Lower chars
      if (password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)) {
        score += 10;
      }

      //password has number and chars
      if (password.match(/([a-zA-Z])/) && password.match(/([0-9])/)) {
        score += 15;
      }

      //password has number and symbol
      if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([0-9])/)) {
        score += 15;
      }

      //password has char and symbol
      if (password.match(/([!,@,#,$,%,^,&,*,?,_,~])/) && password.match(/([a-zA-Z])/)) {
        score += 15;
      }

      //password is just a numbers or chars
      if (password.match(/^\w+$/) || password.match(/^\d+$/) ) {
        score -= 10;
      }

      if (score > Toolbawks.auth.Password.strength_limit) {
        score = Toolbawks.auth.Password.strength_limit;
      }
      
      return score;
    },


    // Author: Firas Kassem  phiras.wordpress.com || phiras at gmail {dot} com
    // for more information : http://phiras.wordpress.com/2007/04/08/password-strength-meter-a-jquery-plugin/
    //
    // Examples:
    //   Toolbawks.auth.Password.check_repetition(1,'aaaaaaabcbc')   = 'abcbc'
    //   Toolbawks.auth.Password.check_repetition(2,'aaaaaaabcbc')   = 'aabc'
    //   Toolbawks.auth.Password.check_repetition(2,'aaaaaaabcdbcd') = 'aabcd'
    check_repetition : function(pLen, str) {
      var unique_characters = "";
      
      // Go through each character of the password
      for (var i = 0; i < str.length; i++) {
        var repeated = true;
        
        // Go through each character of the password conditional if there are more 
        // characters than the current character position plus the repetition string length 
        // which we are checking for
        for (var j = 0; j < pLen && (j + i + pLen) < str.length; j++) {
          repeated = repeated && (str.charAt(j + i) == str.charAt(j + i + pLen));
        }
        
        // if the last character we did the conditional loop on is less than the repitition string length
        // mark as a non-repitive character
        if (j < pLen) {
          repeated = false;
        }
        
        // if this character is repeated, go the end of the repitition for next loop
        // if it's not, add it to the list of characters that are unique
        if (repeated) {
          i += pLen - 1;
        } else {
          unique_characters += str.charAt(i);
        }
      }
      
      // return the number of non-repetitive characters
      return unique_characters;
    }
  };
}();
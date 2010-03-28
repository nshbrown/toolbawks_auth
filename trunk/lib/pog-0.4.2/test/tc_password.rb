require 'test/unit'
require 'base64'
require File.join( File.dirname(__FILE__), '..', 'lib', 'pog.rb' )

TEST_PASS = '/O0op;G75wu3saMv|N9&DA?I*/!3-gqHUe9{VZL{M3YVoYUQ]6q{]Poz%c)V#T,i=g.G8>&'

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

class TC_Password < Test::Unit::TestCase
  def test_to_s
    password = Password.new( TEST_PASS )
    assert_equal(TEST_PASS, password.to_s)
    
    password = Password.new( :new )
    assert_equal false, password.to_s.empty?
  end
  
  def test_hash
    pass = Password.new( TEST_PASS )
    
    # test digests
    assert_equal Digest::SHA256.digest(TEST_PASS), 
                 pass.hash,
                 'hash generation failed for SHA256 digest'
                 
    pass.digest = :sha512
    assert_equal Digest::SHA512.digest(TEST_PASS), 
                 pass.hash,
                 'hash generation failed for SHA512 digest'
                 
    pass.digest = :sha384
    assert_equal Digest::SHA384.digest(TEST_PASS), 
                 pass.hash,
                 'hash generation failed for SHA384 digest'
                 
    pass.digest = :sha1
    assert_equal Digest::SHA1.digest(TEST_PASS), 
                 pass.hash,
                 'hash generation failed for SHA1 digest'
                 
    pass.digest = :md5
    assert_equal Digest::MD5.digest(TEST_PASS), 
                 pass.hash,
                 'hash generation failed for MD5 digest'
                 
    # test formats
    pass.digest = :sha256
    
    assert_equal Digest::SHA256.hexdigest(TEST_PASS), 
                 pass.hash( :hex ), 
                 'hash generation failed for default (hexidecimal) format'
                 
    assert_equal Base64.encode64( Digest::SHA256.digest(TEST_PASS) ).gsub(/\s+/, ''), 
                 pass.hash( :base64 ),
                 'hash generation failed for base64 format'
  end

  def test_authenticate
    pass = Password.new( TEST_PASS, Salt.new )

    assert pass.authenticate(Digest::SHA256.digest(TEST_PASS + pass.salt.to_s))
    assert_equal false, pass.authenticate(Digest::SHA256.digest(pass.salt.to_s + TEST_PASS))
    
    assert pass.authenticate(Digest::SHA1.digest(TEST_PASS + pass.salt.to_s))
    assert pass.authenticate(Digest::SHA384.hexdigest(TEST_PASS + pass.salt.to_s))
    assert pass.authenticate(Digest::SHA512.digest(TEST_PASS + pass.salt.to_s))
    
    md5_b64 = [Digest::MD5.digest(TEST_PASS + pass.salt.to_s)].pack('m').gsub(/\s+/, '')
    assert pass.authenticate( md5_b64 )
  end
end
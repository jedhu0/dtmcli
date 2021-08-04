gem 'minitest'
require 'minitest/pride'
require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../lib/dtmcli'

class Minitest::Test
  def mocking!
    @dtm_host = 'http://127.0.0.1:8080'
    @dtm_url = @dtm_host + '/api/dtm'

    @host = 'http://127.0.0.1:3000'
    @try_url = @host + '/api/try'
    @confirm_url = @host + '/api/confirm'
    @cancel_url = @host + '/api/cancel'

    @out_try_url = @host + '/api/TransOutTry'
    @out_confirm_url = @host + '/api/TransOutConfirm'
    @out_cancel_url = @host + '/api/TransOutCancel'
    @in_try_url = @host + '/api/TransInTry'
    @in_confirm_url = @host + '/api/TransInConfirm'
    @in_cancel_url = @host + '/api/TransInCancel'

    @headers = {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
    }
    @protocol_http_success = {dtm_result: 'SUCCESS'}.to_json
    @protocol_http_failure = {dtm_result: 'FAILURE'}.to_json
  end
end
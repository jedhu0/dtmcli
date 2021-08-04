require 'helper'

class TestTcc < Minitest::Test
  def setup
    mocking!
  end

  def test_initialize
    tcc = Dtmcli::Tcc.new('dtmurl', 'testgid')
    assert_equal 'dtmurl', tcc.dtm_url
    assert_equal 'testgid', tcc.gid
    assert_equal '', tcc.id_gen.parent_id
    assert_equal 0, tcc.id_gen.branch_id
  end

  def test_call_branch_succ
    tcc = Dtmcli::Tcc.new(@dtm_url, 'testgid0')
    body = {a: 'a', b: 'b'}
    url_encoded = '?branch_id=1&branch_type=try&gid=testgid0&trans_type=tcc'

    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    stub_request(:post, @try_url + url_encoded).
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    tcc.call_branch(body, @try_url, @confirm_url, @cancel_url)
    assert_equal 1, tcc.id_gen.branch_id
  end

  def test_call_branch_fail1
    tcc = Dtmcli::Tcc.new(@dtm_url, 'testgid1')
    body = {a: 'a', b: 'b'}

    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
    )

    assert_raises {
      tcc.call_branch(body, @try_url, @confirm_url, @cancel_url)
    }
    assert_equal 1, tcc.id_gen.branch_id
  end

  def test_call_branch_fail2
    tcc = Dtmcli::Tcc.new(@dtm_url, 'testgid1')
    body = {a: 'a', b: 'b'}
    url_encoded = '?branch_id=1&branch_type=try&gid=testgid1&trans_type=tcc'

    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    stub_request(:post, @try_url + url_encoded).
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
    )

    assert_raises {
      tcc.call_branch(body, @try_url, @confirm_url, @cancel_url)
    }
    assert_equal 1, tcc.id_gen.branch_id
  end

  def test_tcc_global_transaction_succ_with_2_branchs
    gid = 'tcc_global_transaction_succ'
    url_encoded1 = "?branch_id=1&branch_type=try&gid=#{gid}&trans_type=tcc"
    url_encoded2 = "?branch_id=2&branch_type=try&gid=#{gid}&trans_type=tcc"

    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/submit").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    stub_request(:post, @out_try_url + url_encoded1).
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    stub_request(:post, @in_try_url + url_encoded2).
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    res = Dtmcli::Tcc.tcc_global_transaction(@dtm_url) do |tcc|
      body = {amount: 30}
      print "calling trans out\n"
      tcc.call_branch(body, @out_try_url, @out_confirm_url, @out_cancel_url)
      print "calling trans in\n"
      tcc.call_branch(body, @in_try_url, @in_confirm_url, @in_cancel_url)

      assert_equal 2, tcc.id_gen.branch_id
    end

    assert_equal gid, res
  end

  def test_tcc_global_transaction_fail1
    gid = 'tcc_global_transaction_fail1'

    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
      )

    assert_raises {
      res = Dtmcli::Tcc.tcc_global_transaction(@dtm_url) do |tcc|
        body = {amount: 30}
        tcc.call_branch(body, @out_try_url, @out_confirm_url, @out_cancel_url)
      end
    }
  end

  def test_tcc_global_transaction_fail2
    gid = 'tcc_global_transaction_fail2'

    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
      )

    stub_request(:post, @dtm_url + "/abort").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success,
      )

    res = Dtmcli::Tcc.tcc_global_transaction(@dtm_url) do |tcc|
      body = {amount: 30}
      tcc.call_branch(body, @out_try_url, @out_confirm_url, @out_cancel_url)
    end

    assert_equal '', res
  end

  def test_tcc_global_transaction_fail3
    gid = 'tcc_global_transaction_fail3'

    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/abort").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success,
      )
    
    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
    )

    res = Dtmcli::Tcc.tcc_global_transaction(@dtm_url) do |tcc|
      body = {amount: 30}
      tcc.call_branch(body, @out_try_url, @out_confirm_url, @out_cancel_url)
      assert_equal 1, tcc.id_gen.branch_id
    end

    assert_equal '', res
  end

  def test_tcc_global_transaction_fail4
    gid = 'tcc_global_transaction_fail4'
    url_encoded1 = "?branch_id=1&branch_type=try&gid=#{gid}&trans_type=tcc"

    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/abort").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success,
      )
    
    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
    )

    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    stub_request(:post, @out_try_url + url_encoded1).
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
    )

    res = Dtmcli::Tcc.tcc_global_transaction(@dtm_url) do |tcc|
      body = {amount: 30}
      tcc.call_branch(body, @out_try_url, @out_confirm_url, @out_cancel_url)
      assert_equal 1, tcc.id_gen.branch_id
    end

    assert_equal '', res
  end

  def test_tcc_global_transaction_fail5
    gid = 'tcc_global_transaction_fail5'
    url_encoded1 = "?branch_id=1&branch_type=try&gid=#{gid}&trans_type=tcc"
    url_encoded2 = "?branch_id=2&branch_type=try&gid=#{gid}&trans_type=tcc"

    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: gid}.to_json,
      )

    stub_request(:post, @dtm_url + "/submit").
      with(headers: @headers).
      to_return(
        status: 500,
        body: 'Internal Server Error'
      )

    stub_request(:post, @dtm_url + "/abort").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success,
      )

    stub_request(:post, @dtm_url + "/registerTccBranch").
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    stub_request(:post, @out_try_url + url_encoded1).
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    stub_request(:post, @in_try_url + url_encoded2).
      with(headers: @headers).
      to_return(
        status: 200,
        body: @protocol_http_success
    )

    res = Dtmcli::Tcc.tcc_global_transaction(@dtm_url) do |tcc|
      body = {amount: 30}
      print "calling trans out\n"
      tcc.call_branch(body, @out_try_url, @out_confirm_url, @out_cancel_url)
      print "calling trans in\n"
      tcc.call_branch(body, @in_try_url, @in_confirm_url, @in_cancel_url)

      assert_equal 2, tcc.id_gen.branch_id
    end

    assert_equal '', res
  end

end

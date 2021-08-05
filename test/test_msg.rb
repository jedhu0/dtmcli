require 'helper'

class TestMsg < Minitest::Test
  def setup
    mocking!
  end

  def test_initialize
    saga = Dtmcli::Msg.new('dtmurl')
    assert_equal 'dtmurl', saga.dtm_url
    assert_equal [], saga.steps
    assert_equal '', saga.query_prepared
  end

  def test_gen_gid_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    dtm_msg.gen_gid
    assert_equal 'test_gid', dtm_msg.gid
  end

  def test_gen_gid_fail
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(status: 200, body: {dtm_result: 'FAILURE', gid: ''}.to_json)

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    assert_raises(Dtmcli::DtmSvrError) {
      dtm_msg.gen_gid
    }
  end

  def test_add_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    assert_equal [], dtm_msg.steps
    dtm_msg.gen_gid

    post_data = {amount: 30}
    dtm_msg.add(@host + '/TransOut1', post_data)
    assert_equal 1, dtm_msg.steps.size
    step1 = dtm_msg.steps[0]
    assert_equal @host + '/TransOut1', step1[:action]

    dtm_msg.add(@host + '/TransOut2', post_data)
    assert_equal 2, dtm_msg.steps.size
    step2 = dtm_msg.steps[1]
    assert_equal @host + '/TransOut2', step2[:action]
  end

  def test_prepare_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
      )

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    assert_equal [], dtm_msg.steps
    dtm_msg.gen_gid

    post_data = {amount: 30}
    dtm_msg.add(@host + '/TransOut1', post_data)

    dtm_msg.prepare(@host + '/TransQuery')
    assert_equal @host + '/TransQuery', dtm_msg.query_prepared
  end

  def test_prepare_fail
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'FAILURE', gid: ''}.to_json,
      )

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    assert_equal [], dtm_msg.steps
    dtm_msg.gen_gid

    post_data = {amount: 30}
    dtm_msg.add(@host + '/TransOut1', post_data)

    assert_raises(Dtmcli::DtmSvrError) {
      dtm_msg.prepare(@host + '/TransQuery')
    }
  end

  def test_wrap_tbody
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
      )

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    assert_equal [], dtm_msg.steps
    dtm_msg.gen_gid

    post_data = {amount: 30}
    dtm_msg.add(@host + '/TransOut1', post_data)

    dtm_msg.prepare(@host + '/TransQuery')

    tbody = dtm_msg.wrap_tbody
    assert_equal 'test_gid', tbody[:gid]
    assert_equal 'msg', tbody[:trans_type]
    assert_equal 1, tbody[:steps].size
    assert_equal @host + '/TransQuery', tbody[:query_prepared]
  end

  def test_submit_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
      )

    stub_request(:post, @dtm_url + "/submit").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
      )

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    assert_equal [], dtm_msg.steps
    dtm_msg.gen_gid

    post_data = {amount: 30}
    dtm_msg.add(@host + '/TransOut1', post_data)

    dtm_msg.prepare(@host + '/TransQuery')
    assert_equal @host + '/TransQuery', dtm_msg.query_prepared

    res = dtm_msg.submit
    assert_equal 'SUCCESS', res['dtm_result']
  end

  def test_submit_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    stub_request(:post, @dtm_url + "/prepare").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
      )

    stub_request(:post, @dtm_url + "/submit").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'FAILURE', gid: ''}.to_json,
      )

    dtm_msg = Dtmcli::Msg.new(@dtm_url)
    assert_equal [], dtm_msg.steps
    dtm_msg.gen_gid

    post_data = {amount: 30}
    dtm_msg.add(@host + '/TransOut1', post_data)

    dtm_msg.prepare(@host + '/TransQuery')
    assert_equal @host + '/TransQuery', dtm_msg.query_prepared

    assert_raises(Dtmcli::DtmSvrError) {
      dtm_msg.submit
    }
  end
end
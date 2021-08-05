require 'helper'

class TestSaga < Minitest::Test
  def setup
    mocking!
  end

  def test_initialize
    saga = Dtmcli::Saga.new('dtmurl')
    assert_equal 'dtmurl', saga.dtm_url
    assert_equal [], saga.steps
  end

  def test_gen_gid_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    saga = Dtmcli::Saga.new(@dtm_url)
    saga.gen_gid
    assert_equal 'test_gid', saga.gid
  end

  def test_gen_gid_fail
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(status: 200, body: {dtm_result: 'FAILURE', gid: ''}.to_json)

    saga = Dtmcli::Saga.new(@dtm_url)
    assert_raises(Dtmcli::DtmSvrError) {
      saga.gen_gid
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

    saga = Dtmcli::Saga.new(@dtm_url)
    assert_equal [], saga.steps
    saga.gen_gid

    post_data = {
      amount:         30,
      transInResult:  "SUCCESS",
      transOutResult: "SUCCESS",
    }
    saga.add(@host + '/TransOut1', @host + '/TransOutRevert1', post_data)
    assert_equal 1, saga.steps.size
    step1 = saga.steps[0]
    assert_equal @host + '/TransOut1', step1[:action]
    assert_equal @host + '/TransOutRevert1', step1[:compensate]
    assert step1[:data].include?('SUCCESS')

    saga.add(@host + '/TransOut2', @host + '/TransOutRevert2', post_data)
    assert_equal 2, saga.steps.size
    step2 = saga.steps[1]
    assert_equal @host + '/TransOut2', step2[:action]
    assert_equal @host + '/TransOutRevert2', step2[:compensate]
    assert step1[:data].include?('SUCCESS')
  end

  def test_submit_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    stub_request(:post, @dtm_url + "/submit").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
      )

    saga = Dtmcli::Saga.new(@dtm_url)
    assert_equal [], saga.steps
    saga.gen_gid

    post_data = {
      amount:         30,
      transInResult:  "SUCCESS",
      transOutResult: "SUCCESS",
    }
    saga.add(@host + '/TransOut', @host + '/TransOutRevert', post_data)
    assert_equal 1, saga.steps.size

    res = saga.submit
    assert_equal 'SUCCESS', res['dtm_result']
  end

  def test_submit_fail
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )

    stub_request(:post, @dtm_url + "/submit").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'FAILURE', gid: ''}.to_json,
      )

    saga = Dtmcli::Saga.new(@dtm_url)
    assert_equal [], saga.steps
    saga.gen_gid

    post_data = {
      amount:         30,
      transInResult:  "SUCCESS",
      transOutResult: "SUCCESS",
    }
    saga.add(@host + '/TransOut', @host + '/TransOutRevert', post_data)
    assert_equal 1, saga.steps.size

    assert_raises(Dtmcli::DtmSvrError) {
      saga.submit
    }
  end
end
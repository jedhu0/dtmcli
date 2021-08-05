require 'helper'

class TestIdGenerator < Minitest::Test
  def setup
    mocking!
  end

  def test_initialize
    id_gen = Dtmcli::IdGenerator.new
    assert_equal '', id_gen.parent_id
    assert_equal 0, id_gen.branch_id
  end

  def test_gen_branch_id
    id_gen = Dtmcli::IdGenerator.new

    id_gen.gen_branch_id
    assert_equal 1, id_gen.branch_id

    res = id_gen.gen_branch_id
    assert_equal 2, id_gen.branch_id
    assert_equal '2', res

    id_gen.branch_id = 99
    assert_raises {
      id_gen.gen_branch_id
    }

    id_gen2 = Dtmcli::IdGenerator.new
    id_gen2.parent_id = '012345678901234567891'
    assert_raises {
      id_gen2.gen_branch_id
    }
  end

  def test_gen_gid_succ
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(
        status: 200,
        body: {dtm_result: 'SUCCESS', gid: 'test_gid'}.to_json,
        headers: {}
      )
    
    res = Dtmcli::IdGenerator.gen_gid(@dtm_url)
    assert_equal 'test_gid', res
  end

  def test_gen_gid_fail
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(status: 500, body: "Internal Server Error")
    
    assert_raises {
      Dtmcli::IdGenerator.gen_gid(@dtm_url)
    }
  end

  def test_gen_gid_fail2
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(status: 200, body: '')
    
    assert_raises {
      Dtmcli::IdGenerator.gen_gid(@dtm_url)
    }
  end

  def test_gen_gid_fail3
    stub_request(:get, @dtm_url + "/newGid").
      with(headers: @headers).
      to_return(status: 200, body: {dtm_result: 'FAILURE', gid: ''}.to_json)
    
    assert_raises(Dtmcli::DtmSvrError) {
      Dtmcli::IdGenerator.gen_gid(@dtm_url)
    }
  end
end

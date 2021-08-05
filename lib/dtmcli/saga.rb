module Dtmcli
  class Saga
    attr_accessor :gid, :steps
    attr_reader :dtm, :dtm_url

    TRANS_TYPE = 'saga'

    def initialize(dtm_url)
      @dtm_url = dtm_url
      @dtm = Dtm.new(dtm_url)
      @steps = []
    end

    def gen_gid
      @gid = IdGenerator.gen_gid(dtm_url)
    end

    def add(action, compensate, post_data)
      step = {
        action:     action,
        compensate: compensate,
        data:       post_data.to_json,
      }
      @steps << step
    end

    def submit
      tbody = {
        gid: gid,
        trans_type: TRANS_TYPE,
        steps: steps
      }
      dtm.submit(tbody)
    end
  end
end
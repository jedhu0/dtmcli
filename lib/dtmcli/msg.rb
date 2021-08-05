module Dtmcli
  class Msg
    attr_accessor :gid, :steps, :query_prepared
    attr_reader :dtm, :dtm_url

    TRANS_TYPE = 'msg'

    def initialize(dtm_url)
      @dtm_url = dtm_url
      @dtm = Dtm.new(dtm_url)
      @steps = []
      @query_prepared = ''
    end

    def gen_gid
      @gid = IdGenerator.gen_gid(dtm_url)
    end

    def add(action, post_data)
      step = {
        action: action,
        data:   post_data.to_json,
      }
      @steps << step
    end

    def prepare(p_url)
      @query_prepared = p_url if !p_url.nil?
      dtm.prepare(wrap_tbody)
    end

    def submit
      dtm.submit(wrap_tbody)
    end

    def wrap_tbody
      {
        gid:            gid,
        trans_type:     TRANS_TYPE,
        steps:          steps,
        query_prepared: query_prepared
      }
    end
  end
end
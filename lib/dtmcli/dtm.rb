module Dtmcli
  class Dtm
    attr_reader :dtm_url

    class << self
      def succ?(data)
        data['dtm_result'] == 'SUCCESS'
      end

      def parse
        Proc.new do |resp|
          body = JSON.parse(resp.body)
          raise DtmSvrError, "dtm server error: data = #{body}" if !succ?(body)
          body
        end
      end

      def new_gid(dtm_url)
        data = Proxy.execute(:get, dtm_url + '/newGid', {}, &parse)
        return data["gid"]
      end
    end

    def initialize(dtm_url)
      @dtm_url = dtm_url
    end

    def prepare(body)
      Proxy.execute(:post, dtm_url + '/prepare', {body: body}, &Dtm::parse)
    end

    def submit(body)
      Proxy.execute(:post, dtm_url + '/submit', {body: body}, &Dtm::parse)
    end

    def abort(body)
      Proxy.execute(:post, dtm_url + '/abort', {body: body}, &Dtm::parse)
    end

    def register_xa_branch(body)
      Proxy.execute(:post, dtm_url + '/registerXaBranch',{body: body}, &Dtm::parse)
    end

    def register_tcc_branch(body)
      Proxy.execute(:post, dtm_url + '/registerTccBranch',{body: body}, &Dtm::parse)
    end

    def query(params)
      Proxy.execute(:get, dtm_url + '/query',{params: params}, &Dtm::parse)
    end
  end
end
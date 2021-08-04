module Dtmcli
  module Proxy
    extend self

    def execute(method, url, opts={}, &block)
      resp = Faraday.send(method, url) do |req|
        req.headers = opts[:headers] || {'Content-Type'=>'application/json'}
        req.params  = opts[:params]  || {}
        req.body    = opts[:body]    || {}
      end

      check_status(resp)
      yield resp if block
    end

    def check_status(resp)
      code = resp.status
      if code != 200
        raise "Dtmcli rpc error: bad http response status = #{code} resp = #{resp.to_hash}"
      end
      return resp
    end
  end
end

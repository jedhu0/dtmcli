module Dtmcli
  class Tcc
    attr_accessor :id_gen
    attr_accessor :dtm_url, :gid

    TRANS_TYPE = 'tcc'

    class << self
      def tcc_global_transaction(dtm_url, &block)
        gid = IdGenerator.gen_gid(dtm_url)
        tcc = Tcc.new(dtm_url, gid)

        tbody = {
          gid: gid,
          trans_type: TRANS_TYPE
        }

        begin
          Proxy.execute(:post, dtm_url + '/prepare', {body: tbody})
          yield tcc if block

          Proxy.execute(:post, dtm_url + '/submit', {body: tbody})
        rescue => e
          Proxy.execute(:post, dtm_url + '/abort', {body: tbody})
          return ''
        end

        return tcc.gid
      end
    end

    def initialize(dtm_url, gid)
      @dtm_url = dtm_url
      @gid = gid
      @id_gen = IdGenerator.new
    end

    def call_branch(body, try_url, confirm_url, cancel_url)
      branch_id = id_gen.gen_branch_id

      Proxy.execute(
        :post,
        dtm_url + '/registerTccBranch',
        {
          body: {
            gid: gid,
            branch_id: branch_id,
            trans_type: TRANS_TYPE,
            status: 'prepared',
            data: body.to_json,
            try: try_url,
            confirm: confirm_url,
            cancel: cancel_url
          }
        }
      )

      Proxy.execute(
        :post,
        try_url,
        {
          body: body,
          params: {
            gid: gid,
            trans_type: TRANS_TYPE,
            branch_id: branch_id,
            branch_type: 'try'
          }
        }
      )
    end
  end
end
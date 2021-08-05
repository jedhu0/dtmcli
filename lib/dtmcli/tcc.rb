module Dtmcli
  class Tcc
    attr_accessor :id_gen, :gid
    attr_reader :dtm, :dtm_url

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
          tcc.dtm.prepare(tbody)

          yield tcc if block

          tcc.dtm.submit(tbody)
        rescue => e
          tcc.dtm.abort(tbody)
          return ''
        end

        return tcc.gid
      end
    end

    def initialize(dtm_url, gid)
      @dtm_url = dtm_url
      @gid = gid
      @id_gen = IdGenerator.new
      @dtm = Dtm.new(dtm_url)
    end

    def call_branch(body, try_url, confirm_url, cancel_url)
      branch_id = id_gen.gen_branch_id

      dtm.register_tcc_branch({
        gid: gid,
        branch_id: branch_id,
        trans_type: TRANS_TYPE,
        status: 'prepared',
        data: body.to_json,
        try: try_url,
        confirm: confirm_url,
        cancel: cancel_url
      })

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
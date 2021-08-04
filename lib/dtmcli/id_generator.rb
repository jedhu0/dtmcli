module Dtmcli
  class IdGenerator
    attr_reader :id_gen
    attr_accessor :parent_id, :branch_id

    class << self
      def gen_gid(dtmUrl)
        body = Proxy.execute(:get, dtmUrl + '/newGid') do |resp|
          JSON.parse(resp.body)
        end
        return body["gid"]
      end
    end

    def initialize(parent_id=nil, branch_id=nil)
      @parent_id = parent_id || ''
      @branch_id = branch_id || 0
    end

    def gen_branch_id
      raise 'branch id is lager than 99' if branch_id >= 99
      raise 'total branch id is longer than 20' if parent_id.size >= 20
      @branch_id = branch_id + 1
      return "#{parent_id}#{branch_id}"
    end
  end
end
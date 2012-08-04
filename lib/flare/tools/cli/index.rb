# -*- coding: utf-8; -*-
# Authors::   Kiyoshi Ikehara <kiyoshi.ikehara@gree.net>
# Copyright:: Copyright (C) GREE, Inc. 2011.
# License::   MIT-style

require 'flare/tools/stats'
require 'flare/tools/common'
require 'flare/tools/cluster'
require 'flare/tools/cli/sub_command'
require 'flare/util/conversion'

module Flare
  module Tools
    module Cli
      class Index < SubCommand
        include Flare::Util::Conversion
        
        myname :index
        desc   "print the index XML document from a cluster information."
        usage  "index"

        def setup(opt)
          opt.on('--indexdb=URI',            "index database"        ) {|v| @indexdb = v}
          opt.on('--output=FILE',            "output index to a file") {|v| @output = v}
        end

        def initialize
          super
          @output = nil
          @indexdb = nil
        end

        def execute(config, *args)
          cluster = Flare::Tools::Stats.open(config[:index_server_hostname], config[:index_server_port], config[:timeout]) do |s|
            nodes = s.stats_nodes.sort_by{|key, val| [val['partition'], val['role'], key]}
            Flare::Tools::Cluster.new(s.host, s.port, s.stats_nodes)
          end

          output = cluster.serialize
          if @output.nil?
            info output
          else
            open(@output, "w") do |f|
              f.write(output)
            end
          end

          S_OK
        end
      end
    end
  end
end


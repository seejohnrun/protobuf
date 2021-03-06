require 'resolv'

module Protobuf
  module Rpc
    module Zmq

      ADDRESS_MATCH = /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/.freeze
      WORKER_READY_MESSAGE = "\1"
      CHECK_AVAILABLE_MESSAGE = "\3"
      NO_WORKERS_AVAILABLE = "\4"
      WORKERS_AVAILABLE = "\5"
      EMPTY_STRING = ""

      module Util
        include ::Protobuf::Logging

        def self.included(base)
          base.extend(::Protobuf::Rpc::Zmq::Util)
        end

        def zmq_error_check(return_code, source = nil)
          unless ::ZMQ::Util.resultcode_ok?(return_code)
            fail <<-ERROR
            Last ZMQ API call #{source ? "to #{source}" : ""} failed with "#{::ZMQ::Util.error_string}".

            #{caller(1).join($INPUT_RECORD_SEPARATOR)}
            ERROR
          end
        end

        def log_signature
          unless @_log_signature
            name = (self.class == Class ? self.name : self.class.name)
            @_log_signature = "[server-#{name}-#{object_id}]"
          end

          @_log_signature
        end

        def resolve_ip(hostname)
          ::Resolv.getaddresses(hostname).find do |address|
            address =~ ADDRESS_MATCH
          end
        end
      end
    end
  end
end

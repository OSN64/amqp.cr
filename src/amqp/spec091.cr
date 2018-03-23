module AMQP::Protocol
  FRAME_METHOD = 1

  FRAME_HEADER = 2

  FRAME_BODY = 3

  FRAME_HEARTBEAT = 8

  FRAME_MIN_SIZE = 4096

  FRAME_END = 206

  REPLY_SUCCESS = 200

  class ContentTooLarge < SoftError
    VALUE = 311
  end


  class NoConsumers < SoftError
    VALUE = 313
  end


  class ConnectionForced < HardError
    VALUE = 320
  end


  class InvalidPath < HardError
    VALUE = 402
  end


  class AccessRefused < SoftError
    VALUE = 403
  end


  class NotFound < SoftError
    VALUE = 404
  end


  class ResourceLocked < SoftError
    VALUE = 405
  end


  class PreconditionFailed < SoftError
    VALUE = 406
  end


  class FrameError < HardError
    VALUE = 501
  end


  class SyntaxError < HardError
    VALUE = 502
  end


  class CommandInvalid < HardError
    VALUE = 503
  end


  class ChannelError < HardError
    VALUE = 504
  end


  class UnexpectedFrame < HardError
    VALUE = 505
  end


  class ResourceError < HardError
    VALUE = 506
  end


  class NotAllowed < HardError
    VALUE = 530
  end


  class NotImplemented < HardError
    VALUE = 540
  end


  class InternalError < HardError
    VALUE = 541
  end


  module Connection
    INDEX = 10_u16

    class Start < Method
      INDEX = 10_u16

      getter version_major, version_minor, server_properties, mechanisms, locales

      def initialize(@version_major : UInt8, @version_minor : UInt8, @server_properties : Hash(String, AMQP::Protocol::Field), @mechanisms : String, @locales : String)
      end

      def id
        [10_u16, 10_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        version_major = io.read_octet
        raise ::IO::EOFError.new unless version_major
        version_minor = io.read_octet
        raise ::IO::EOFError.new unless version_minor
        server_properties = io.read_table
        raise ::IO::EOFError.new unless server_properties
        mechanisms = io.read_longstr
        raise ::IO::EOFError.new unless mechanisms
        locales = io.read_longstr
        raise ::IO::EOFError.new unless locales
        Start.new(version_major, version_minor, server_properties, mechanisms, locales)
      end

      def encode(io)
        io.write_octet(@version_major)
        io.write_octet(@version_minor)
        io.write_table(@server_properties)
        io.write_longstr(@mechanisms)
        io.write_longstr(@locales)
      end

      def to_s(io)
        io << "Connection.Start("
        io << "version_major: "
        version_major.inspect(io)
        io << ", "
        io << "version_minor: "
        version_minor.inspect(io)
        io << ", "
        io << "server_properties: "
        server_properties.inspect(io)
        io << ", "
        io << "mechanisms: "
        mechanisms.inspect(io)
        io << ", "
        io << "locales: "
        locales.inspect(io)
        io << ")"
      end
    end

    class StartOk < Method
      INDEX = 11_u16

      getter client_properties, mechanism, response, locale

      def initialize(@client_properties :  Hash(String, AMQP::Protocol::Field), @mechanism : String, @response : String, @locale : String)
      end

      def id
        [10_u16, 11_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        client_properties = io.read_table
        raise ::IO::EOFError.new unless client_properties
        mechanism = io.read_shortstr
        raise ::IO::EOFError.new unless mechanism
        response = io.read_longstr
        raise ::IO::EOFError.new unless response
        locale = io.read_shortstr
        raise ::IO::EOFError.new unless locale
        StartOk.new(client_properties, mechanism, response, locale)
      end

      def encode(io)
        io.write_table(@client_properties)
        io.write_shortstr(@mechanism)
        io.write_longstr(@response)
        io.write_shortstr(@locale)
      end

      def to_s(io)
        io << "Connection.StartOk("
        io << "client_properties: "
        client_properties.inspect(io)
        io << ", "
        io << "mechanism: "
        mechanism.inspect(io)
        io << ", "
        io << "response: "
        response.inspect(io)
        io << ", "
        io << "locale: "
        locale.inspect(io)
        io << ")"
      end
    end

    class Secure < Method
      INDEX = 20_u16

      getter challenge

      def initialize(@challenge : String)
      end

      def id
        [10_u16, 20_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        challenge = io.read_longstr
        raise ::IO::EOFError.new unless challenge
        Secure.new(challenge)
      end

      def encode(io)
        io.write_longstr(@challenge)
      end

      def to_s(io)
        io << "Connection.Secure("
        io << "challenge: "
        challenge.inspect(io)
        io << ")"
      end
    end

    class SecureOk < Method
      INDEX = 21_u16

      getter response

      def initialize(@response : String )
      end

      def id
        [10_u16, 21_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        response = io.read_longstr
        raise ::IO::EOFError.new unless response
        SecureOk.new(response)
      end

      def encode(io)
        io.write_longstr(@response)
      end

      def to_s(io)
        io << "Connection.SecureOk("
        io << "response: "
        response.inspect(io)
        io << ")"
      end
    end

    class Tune < Method
      INDEX = 30_u16

      getter channel_max, frame_max, heartbeat

      def initialize(@channel_max : UInt16, @frame_max : UInt32, @heartbeat : UInt16)
      end

      def id
        [10_u16, 30_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        channel_max = io.read_short
        raise ::IO::EOFError.new unless channel_max
        frame_max = io.read_long
        raise ::IO::EOFError.new unless frame_max
        heartbeat = io.read_short
        raise ::IO::EOFError.new unless heartbeat
        Tune.new(channel_max, frame_max, heartbeat)
      end

      def encode(io)
        io.write_short(@channel_max)
        io.write_long(@frame_max)
        io.write_short(@heartbeat)
      end

      def to_s(io)
        io << "Connection.Tune("
        io << "channel_max: "
        channel_max.inspect(io)
        io << ", "
        io << "frame_max: "
        frame_max.inspect(io)
        io << ", "
        io << "heartbeat: "
        heartbeat.inspect(io)
        io << ")"
      end
    end

    class TuneOk < Method
      INDEX = 31_u16

      getter channel_max, frame_max, heartbeat

      def initialize(@channel_max : UInt16, @frame_max : UInt32, @heartbeat : UInt16)
      end

      def id
        [10_u16, 31_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        channel_max = io.read_short
        raise ::IO::EOFError.new unless channel_max
        frame_max = io.read_long
        raise ::IO::EOFError.new unless frame_max
        heartbeat = io.read_short
        raise ::IO::EOFError.new unless heartbeat
        TuneOk.new(channel_max, frame_max, heartbeat)
      end

      def encode(io)
        io.write_short(@channel_max)
        io.write_long(@frame_max)
        io.write_short(@heartbeat)
      end

      def to_s(io)
        io << "Connection.TuneOk("
        io << "channel_max: "
        channel_max.inspect(io)
        io << ", "
        io << "frame_max: "
        frame_max.inspect(io)
        io << ", "
        io << "heartbeat: "
        heartbeat.inspect(io)
        io << ")"
      end
    end

    class Open < Method
      INDEX = 40_u16

      getter virtual_host, reserved_1, reserved_2

      def initialize(@virtual_host : String, @reserved_1 : String, @reserved_2 : Bool)
      end

      def id
        [10_u16, 40_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        virtual_host = io.read_shortstr
        raise ::IO::EOFError.new unless virtual_host
        reserved_1 = io.read_shortstr
        raise ::IO::EOFError.new unless reserved_1
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        reserved_2 = bits & (1 << 0) == 1
        Open.new(virtual_host, reserved_1, reserved_2)
      end

      def encode(io)
        io.write_shortstr(@virtual_host)
        io.write_shortstr(@reserved_1)
        bits = 0_u8
        bits = bits | (1 << 0) if @reserved_2
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Connection.Open("
        io << "virtual_host: "
        virtual_host.inspect(io)
        io << ", "
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "reserved_2: "
        reserved_2.inspect(io)
        io << ")"
      end
    end

    class OpenOk < Method
      INDEX = 41_u16

      getter reserved_1

      def initialize(@reserved_1 : String)
      end

      def id
        [10_u16, 41_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_shortstr
        raise ::IO::EOFError.new unless reserved_1
        OpenOk.new(reserved_1)
      end

      def encode(io)
        io.write_shortstr(@reserved_1)
      end

      def to_s(io)
        io << "Connection.OpenOk("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ")"
      end
    end

    class Close < Method
      INDEX = 50_u16

      getter reply_code, reply_text, class_id, method_id

      def initialize(@reply_code : UInt16, @reply_text : String, @class_id : UInt16, @method_id : UInt16)
      end

      def id
        [10_u16, 50_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reply_code = io.read_short
        raise ::IO::EOFError.new unless reply_code
        reply_text = io.read_shortstr
        raise ::IO::EOFError.new unless reply_text
        class_id = io.read_short
        raise ::IO::EOFError.new unless class_id
        method_id = io.read_short
        raise ::IO::EOFError.new unless method_id
        Close.new(reply_code, reply_text, class_id, method_id)
      end

      def encode(io)
        io.write_short(@reply_code)
        io.write_shortstr(@reply_text)
        io.write_short(@class_id)
        io.write_short(@method_id)
      end

      def to_s(io)
        io << "Connection.Close("
        io << "reply_code: "
        reply_code.inspect(io)
        io << ", "
        io << "reply_text: "
        reply_text.inspect(io)
        io << ", "
        io << "class_id: "
        class_id.inspect(io)
        io << ", "
        io << "method_id: "
        method_id.inspect(io)
        io << ")"
      end
    end

    class CloseOk < Method
      INDEX = 51_u16

      def initialize()
      end

      def id
        [10_u16, 51_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        CloseOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Connection.CloseOk("
        io << ")"
      end
    end

    class Blocked < Method
      INDEX = 60_u16

      getter reason

      def initialize(@reason : String)
      end

      def id
        [10_u16, 60_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        reason = io.read_shortstr
        raise ::IO::EOFError.new unless reason
        Blocked.new(reason)
      end

      def encode(io)
        io.write_shortstr(@reason)
      end

      def to_s(io)
        io << "Connection.Blocked("
        io << "reason: "
        reason.inspect(io)
        io << ")"
      end
    end

    class Unblocked < Method
      INDEX = 61_u16

      def initialize()
      end

      def id
        [10_u16, 61_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        Unblocked.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Connection.Unblocked("
        io << ")"
      end
    end

  end

  module Channel
    INDEX = 20_u16

    class Open < Method
      INDEX = 10_u16

      getter reserved_1

      def initialize(@reserved_1 : String)
      end

      def id
        [20_u16, 10_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_shortstr
        raise ::IO::EOFError.new unless reserved_1
        Open.new(reserved_1)
      end

      def encode(io)
        io.write_shortstr(@reserved_1)
      end

      def to_s(io)
        io << "Channel.Open("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ")"
      end
    end

    class OpenOk < Method
      INDEX = 11_u16

      getter reserved_1

      def initialize(@reserved_1 : String)
      end

      def id
        [20_u16, 11_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_longstr
        raise ::IO::EOFError.new unless reserved_1
        OpenOk.new(reserved_1)
      end

      def encode(io)
        io.write_longstr(@reserved_1)
      end

      def to_s(io)
        io << "Channel.OpenOk("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ")"
      end
    end

    class Flow < Method
      INDEX = 20_u16

      getter active

      def initialize(@active : Bool)
      end

      def id
        [20_u16, 20_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        active = bits & (1 << 0) == 1
        Flow.new(active)
      end

      def encode(io)
        bits = 0_u8
        bits = bits | (1 << 0) if @active
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Channel.Flow("
        io << "active: "
        active.inspect(io)
        io << ")"
      end
    end

    class FlowOk < Method
      INDEX = 21_u16

      getter active

      def initialize(@active : Bool)
      end

      def id
        [20_u16, 21_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        active = bits & (1 << 0) == 1
        FlowOk.new(active)
      end

      def encode(io)
        bits = 0_u8
        bits = bits | (1 << 0) if @active
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Channel.FlowOk("
        io << "active: "
        active.inspect(io)
        io << ")"
      end
    end

    class Close < Method
      INDEX = 40_u16

      getter reply_code, reply_text, class_id, method_id

      def initialize(@reply_code : UInt16, @reply_text : String, @class_id : UInt16, @method_id : UInt16)
      end

      def id
        [20_u16, 40_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reply_code = io.read_short
        raise ::IO::EOFError.new unless reply_code
        reply_text = io.read_shortstr
        raise ::IO::EOFError.new unless reply_text
        class_id = io.read_short
        raise ::IO::EOFError.new unless class_id
        method_id = io.read_short
        raise ::IO::EOFError.new unless method_id
        Close.new(reply_code, reply_text, class_id, method_id)
      end

      def encode(io)
        io.write_short(@reply_code)
        io.write_shortstr(@reply_text)
        io.write_short(@class_id)
        io.write_short(@method_id)
      end

      def to_s(io)
        io << "Channel.Close("
        io << "reply_code: "
        reply_code.inspect(io)
        io << ", "
        io << "reply_text: "
        reply_text.inspect(io)
        io << ", "
        io << "class_id: "
        class_id.inspect(io)
        io << ", "
        io << "method_id: "
        method_id.inspect(io)
        io << ")"
      end
    end

    class CloseOk < Method
      INDEX = 41_u16

      def initialize()
      end

      def id
        [20_u16, 41_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        CloseOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Channel.CloseOk("
        io << ")"
      end
    end

  end

  module Exchange
    INDEX = 40_u16

    class Declare < Method
      INDEX = 10_u16

      getter reserved_1, exchange, type, passive, durable, auto_delete, internal, no_wait, arguments

      def initialize(@reserved_1 : UInt16, @exchange : String, @type : String, @passive : Bool, @durable : Bool, @auto_delete : Bool, @internal : Bool, @no_wait : Bool, @arguments : Hash(String, AMQP::Protocol::Field))
      end

      def id
        [40_u16, 10_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        type = io.read_shortstr
        raise ::IO::EOFError.new unless type
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        passive = bits & (1 << 0) == 1
        durable = bits & (1 << 1) == 1
        auto_delete = bits & (1 << 2) == 1
        internal = bits & (1 << 3) == 1
        no_wait = bits & (1 << 4) == 1
        arguments = io.read_table
        raise ::IO::EOFError.new unless arguments
        Declare.new(reserved_1, exchange, type, passive, durable, auto_delete, internal, no_wait, arguments)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@exchange)
        io.write_shortstr(@type)
        bits = 0_u8
        bits = bits | (1 << 0) if @passive
        bits = bits | (1 << 1) if @durable
        bits = bits | (1 << 2) if @auto_delete
        bits = bits | (1 << 3) if @internal
        bits = bits | (1 << 4) if @no_wait
        io.write_octet(bits)
        io.write_table(@arguments)
      end

      def to_s(io)
        io << "Exchange.Declare("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "type: "
        type.inspect(io)
        io << ", "
        io << "passive: "
        passive.inspect(io)
        io << ", "
        io << "durable: "
        durable.inspect(io)
        io << ", "
        io << "auto_delete: "
        auto_delete.inspect(io)
        io << ", "
        io << "internal: "
        internal.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ", "
        io << "arguments: "
        arguments.inspect(io)
        io << ")"
      end
    end

    class DeclareOk < Method
      INDEX = 11_u16

      def initialize()
      end

      def id
        [40_u16, 11_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        DeclareOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Exchange.DeclareOk("
        io << ")"
      end
    end

    class Delete < Method
      INDEX = 20_u16

      getter reserved_1, exchange, if_unused, no_wait

      def initialize(@reserved_1 : UInt16, @exchange : String, @if_unused : Bool, @no_wait : Bool)
      end

      def id
        [40_u16, 20_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        if_unused = bits & (1 << 0) == 1
        no_wait = bits & (1 << 1) == 1
        Delete.new(reserved_1, exchange, if_unused, no_wait)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@exchange)
        bits = 0_u8
        bits = bits | (1 << 0) if @if_unused
        bits = bits | (1 << 1) if @no_wait
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Exchange.Delete("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "if_unused: "
        if_unused.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ")"
      end
    end

    class DeleteOk < Method
      INDEX = 21_u16

      def initialize()
      end

      def id
        [40_u16, 21_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        DeleteOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Exchange.DeleteOk("
        io << ")"
      end
    end

    class Bind < Method
      INDEX = 30_u16

      getter reserved_1, destination, source, routing_key, no_wait, arguments

      def initialize(@reserved_1 : UInt16, @destination : String, @source : String, @routing_key : String, @no_wait : Bool, @arguments : Hash(String, AMQP::Protocol::Field))
      end

      def id
        [40_u16, 30_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        destination = io.read_shortstr
        raise ::IO::EOFError.new unless destination
        source = io.read_shortstr
        raise ::IO::EOFError.new unless source
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        no_wait = bits & (1 << 0) == 1
        arguments = io.read_table
        raise ::IO::EOFError.new unless arguments
        Bind.new(reserved_1, destination, source, routing_key, no_wait, arguments)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@destination)
        io.write_shortstr(@source)
        io.write_shortstr(@routing_key)
        bits = 0_u8
        bits = bits | (1 << 0) if @no_wait
        io.write_octet(bits)
        io.write_table(@arguments)
      end

      def to_s(io)
        io << "Exchange.Bind("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "destination: "
        destination.inspect(io)
        io << ", "
        io << "source: "
        source.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ", "
        io << "arguments: "
        arguments.inspect(io)
        io << ")"
      end
    end

    class BindOk < Method
      INDEX = 31_u16

      def initialize()
      end

      def id
        [40_u16, 31_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        BindOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Exchange.BindOk("
        io << ")"
      end
    end

    class Unbind < Method
      INDEX = 40_u16

      getter reserved_1, destination, source, routing_key, no_wait, arguments

      def initialize(@reserved_1 : UInt16, @destination : String, @source : String, @routing_key : String, @no_wait : Bool, @arguments : Hash(String, AMQP::Protocol::Field))
      end

      def id
        [40_u16, 40_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        destination = io.read_shortstr
        raise ::IO::EOFError.new unless destination
        source = io.read_shortstr
        raise ::IO::EOFError.new unless source
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        no_wait = bits & (1 << 0) == 1
        arguments = io.read_table
        raise ::IO::EOFError.new unless arguments
        Unbind.new(reserved_1, destination, source, routing_key, no_wait, arguments)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@destination)
        io.write_shortstr(@source)
        io.write_shortstr(@routing_key)
        bits = 0_u8
        bits = bits | (1 << 0) if @no_wait
        io.write_octet(bits)
        io.write_table(@arguments)
      end

      def to_s(io)
        io << "Exchange.Unbind("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "destination: "
        destination.inspect(io)
        io << ", "
        io << "source: "
        source.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ", "
        io << "arguments: "
        arguments.inspect(io)
        io << ")"
      end
    end

    class UnbindOk < Method
      INDEX = 51_u16

      def initialize()
      end

      def id
        [40_u16, 51_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        UnbindOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Exchange.UnbindOk("
        io << ")"
      end
    end

  end

  module Queue
    INDEX = 50_u16

    class Declare < Method
      INDEX = 10_u16

      getter reserved_1, queue, passive, durable, exclusive, auto_delete, no_wait, arguments

      def initialize(@reserved_1 : UInt16, @queue : String, @passive : Bool, @durable : Bool, @exclusive : Bool, @auto_delete : Bool, @no_wait : Bool, @arguments : Hash(String, AMQP::Protocol::Field))
      end

      def id
        [50_u16, 10_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        passive = bits & (1 << 0) == 1
        durable = bits & (1 << 1) == 1
        exclusive = bits & (1 << 2) == 1
        auto_delete = bits & (1 << 3) == 1
        no_wait = bits & (1 << 4) == 1
        arguments = io.read_table
        raise ::IO::EOFError.new unless arguments
        Declare.new(reserved_1, queue, passive, durable, exclusive, auto_delete, no_wait, arguments)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@queue)
        bits = 0_u8
        bits = bits | (1 << 0) if @passive
        bits = bits | (1 << 1) if @durable
        bits = bits | (1 << 2) if @exclusive
        bits = bits | (1 << 3) if @auto_delete
        bits = bits | (1 << 4) if @no_wait
        io.write_octet(bits)
        io.write_table(@arguments)
      end

      def to_s(io)
        io << "Queue.Declare("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "passive: "
        passive.inspect(io)
        io << ", "
        io << "durable: "
        durable.inspect(io)
        io << ", "
        io << "exclusive: "
        exclusive.inspect(io)
        io << ", "
        io << "auto_delete: "
        auto_delete.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ", "
        io << "arguments: "
        arguments.inspect(io)
        io << ")"
      end
    end

    class DeclareOk < Method
      INDEX = 11_u16

      getter queue, message_count, consumer_count

      def initialize(@queue : String, @message_count : UInt32, @consumer_count : UInt32)
      end

      def id
        [50_u16, 11_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        message_count = io.read_long
        raise ::IO::EOFError.new unless message_count
        consumer_count = io.read_long
        raise ::IO::EOFError.new unless consumer_count
        DeclareOk.new(queue, message_count, consumer_count)
      end

      def encode(io)
        io.write_shortstr(@queue)
        io.write_long(@message_count)
        io.write_long(@consumer_count)
      end

      def to_s(io)
        io << "Queue.DeclareOk("
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "message_count: "
        message_count.inspect(io)
        io << ", "
        io << "consumer_count: "
        consumer_count.inspect(io)
        io << ")"
      end
    end

    class Bind < Method
      INDEX = 20_u16

      getter reserved_1, queue, exchange, routing_key, no_wait, arguments

      def initialize(@reserved_1 : UInt16, @queue : String, @exchange : String, @routing_key : String, @no_wait : Bool, @arguments : Hash(String, AMQP::Protocol::Field))
      end

      def id
        [50_u16, 20_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        no_wait = bits & (1 << 0) == 1
        arguments = io.read_table
        raise ::IO::EOFError.new unless arguments
        Bind.new(reserved_1, queue, exchange, routing_key, no_wait, arguments)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@queue)
        io.write_shortstr(@exchange)
        io.write_shortstr(@routing_key)
        bits = 0_u8
        bits = bits | (1 << 0) if @no_wait
        io.write_octet(bits)
        io.write_table(@arguments)
      end

      def to_s(io)
        io << "Queue.Bind("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ", "
        io << "arguments: "
        arguments.inspect(io)
        io << ")"
      end
    end

    class BindOk < Method
      INDEX = 21_u16

      def initialize()
      end

      def id
        [50_u16, 21_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        BindOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Queue.BindOk("
        io << ")"
      end
    end

    class Unbind < Method
      INDEX = 50_u16

      getter reserved_1, queue, exchange, routing_key, arguments

      def initialize(@reserved_1 : UInt16, @queue : String, @exchange : String, @routing_key : String, @arguments : Hash(String, AMQP::Protocol::Field))
      end

      def id
        [50_u16, 50_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        arguments = io.read_table
        raise ::IO::EOFError.new unless arguments
        Unbind.new(reserved_1, queue, exchange, routing_key, arguments)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@queue)
        io.write_shortstr(@exchange)
        io.write_shortstr(@routing_key)
        io.write_table(@arguments)
      end

      def to_s(io)
        io << "Queue.Unbind("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "arguments: "
        arguments.inspect(io)
        io << ")"
      end
    end

    class UnbindOk < Method
      INDEX = 51_u16

      def initialize()
      end

      def id
        [50_u16, 51_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        UnbindOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Queue.UnbindOk("
        io << ")"
      end
    end

    class Purge < Method
      INDEX = 30_u16

      getter reserved_1, queue, no_wait

      def initialize(@reserved_1 : UInt16, @queue : String, @no_wait : Bool)
      end

      def id
        [50_u16, 30_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        no_wait = bits & (1 << 0) == 1
        Purge.new(reserved_1, queue, no_wait)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@queue)
        bits = 0_u8
        bits = bits | (1 << 0) if @no_wait
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Queue.Purge("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ")"
      end
    end

    class PurgeOk < Method
      INDEX = 31_u16

      getter message_count

      def initialize(@message_count : UInt32)
      end

      def id
        [50_u16, 31_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        message_count = io.read_long
        raise ::IO::EOFError.new unless message_count
        PurgeOk.new(message_count)
      end

      def encode(io)
        io.write_long(@message_count)
      end

      def to_s(io)
        io << "Queue.PurgeOk("
        io << "message_count: "
        message_count.inspect(io)
        io << ")"
      end
    end

    class Delete < Method
      INDEX = 40_u16

      getter reserved_1, queue, if_unused, if_empty, no_wait

      def initialize(@reserved_1 : UInt16, @queue : String, @if_unused : Bool, @if_empty : Bool, @no_wait : Bool)
      end

      def id
        [50_u16, 40_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        if_unused = bits & (1 << 0) == 1
        if_empty = bits & (1 << 1) == 1
        no_wait = bits & (1 << 2) == 1
        Delete.new(reserved_1, queue, if_unused, if_empty, no_wait)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@queue)
        bits = 0_u8
        bits = bits | (1 << 0) if @if_unused
        bits = bits | (1 << 1) if @if_empty
        bits = bits | (1 << 2) if @no_wait
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Queue.Delete("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "if_unused: "
        if_unused.inspect(io)
        io << ", "
        io << "if_empty: "
        if_empty.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ")"
      end
    end

    class DeleteOk < Method
      INDEX = 41_u16

      getter message_count

      def initialize(@message_count : UInt32)
      end

      def id
        [50_u16, 41_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        message_count = io.read_long
        raise ::IO::EOFError.new unless message_count
        DeleteOk.new(message_count)
      end

      def encode(io)
        io.write_long(@message_count)
      end

      def to_s(io)
        io << "Queue.DeleteOk("
        io << "message_count: "
        message_count.inspect(io)
        io << ")"
      end
    end

  end

  module Basic
    INDEX = 60_u16

    class Qos < Method
      INDEX = 10_u16

      getter prefetch_size, prefetch_count, global

      def initialize(@prefetch_size : UInt32, @prefetch_count : UInt16, @global : Bool)
      end

      def id
        [60_u16, 10_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        prefetch_size = io.read_long
        raise ::IO::EOFError.new unless prefetch_size
        prefetch_count = io.read_short
        raise ::IO::EOFError.new unless prefetch_count
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        global = bits & (1 << 0) == 1
        Qos.new(prefetch_size, prefetch_count, global)
      end

      def encode(io)
        io.write_long(@prefetch_size)
        io.write_short(@prefetch_count)
        bits = 0_u8
        bits = bits | (1 << 0) if @global
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Qos("
        io << "prefetch_size: "
        prefetch_size.inspect(io)
        io << ", "
        io << "prefetch_count: "
        prefetch_count.inspect(io)
        io << ", "
        io << "global: "
        global.inspect(io)
        io << ")"
      end
    end

    class QosOk < Method
      INDEX = 11_u16

      def initialize()
      end

      def id
        [60_u16, 11_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        QosOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Basic.QosOk("
        io << ")"
      end
    end

    class Consume < Method
      INDEX = 20_u16

      getter reserved_1, queue, consumer_tag, no_local, no_ack, exclusive, no_wait, arguments

      def initialize(@reserved_1 : UInt16, @queue : String, @consumer_tag : String, @no_local : Bool, @no_ack : Bool, @exclusive : Bool, @no_wait : Bool, @arguments : Hash(String, AMQP::Protocol::Field))
      end

      def id
        [60_u16, 20_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        consumer_tag = io.read_shortstr
        raise ::IO::EOFError.new unless consumer_tag
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        no_local = bits & (1 << 0) == 1
        no_ack = bits & (1 << 1) == 1
        exclusive = bits & (1 << 2) == 1
        no_wait = bits & (1 << 3) == 1
        arguments = io.read_table
        raise ::IO::EOFError.new unless arguments
        Consume.new(reserved_1, queue, consumer_tag, no_local, no_ack, exclusive, no_wait, arguments)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@queue)
        io.write_shortstr(@consumer_tag)
        bits = 0_u8
        bits = bits | (1 << 0) if @no_local
        bits = bits | (1 << 1) if @no_ack
        bits = bits | (1 << 2) if @exclusive
        bits = bits | (1 << 3) if @no_wait
        io.write_octet(bits)
        io.write_table(@arguments)
      end

      def to_s(io)
        io << "Basic.Consume("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "consumer_tag: "
        consumer_tag.inspect(io)
        io << ", "
        io << "no_local: "
        no_local.inspect(io)
        io << ", "
        io << "no_ack: "
        no_ack.inspect(io)
        io << ", "
        io << "exclusive: "
        exclusive.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ", "
        io << "arguments: "
        arguments.inspect(io)
        io << ")"
      end
    end

    class ConsumeOk < Method
      INDEX = 21_u16

      getter consumer_tag

      def initialize(@consumer_tag : String)
      end

      def id
        [60_u16, 21_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        consumer_tag = io.read_shortstr
        raise ::IO::EOFError.new unless consumer_tag
        ConsumeOk.new(consumer_tag)
      end

      def encode(io)
        io.write_shortstr(@consumer_tag)
      end

      def to_s(io)
        io << "Basic.ConsumeOk("
        io << "consumer_tag: "
        consumer_tag.inspect(io)
        io << ")"
      end
    end

    class Cancel < Method
      INDEX = 30_u16

      getter consumer_tag, no_wait

      def initialize(@consumer_tag : String, @no_wait : Bool)
      end

      def id
        [60_u16, 30_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        consumer_tag = io.read_shortstr
        raise ::IO::EOFError.new unless consumer_tag
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        no_wait = bits & (1 << 0) == 1
        Cancel.new(consumer_tag, no_wait)
      end

      def encode(io)
        io.write_shortstr(@consumer_tag)
        bits = 0_u8
        bits = bits | (1 << 0) if @no_wait
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Cancel("
        io << "consumer_tag: "
        consumer_tag.inspect(io)
        io << ", "
        io << "no_wait: "
        no_wait.inspect(io)
        io << ")"
      end
    end

    class CancelOk < Method
      INDEX = 31_u16

      getter consumer_tag

      def initialize(@consumer_tag : String)
      end

      def id
        [60_u16, 31_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        consumer_tag = io.read_shortstr
        raise ::IO::EOFError.new unless consumer_tag
        CancelOk.new(consumer_tag)
      end

      def encode(io)
        io.write_shortstr(@consumer_tag)
      end

      def to_s(io)
        io << "Basic.CancelOk("
        io << "consumer_tag: "
        consumer_tag.inspect(io)
        io << ")"
      end
    end

    class Publish < Method
      INDEX = 40_u16

      getter reserved_1, exchange, routing_key, mandatory, immediate, properties, payload

      def initialize(@reserved_1 : UInt16, @exchange : String, @routing_key : String, @mandatory : Bool, @immediate : Bool, @properties : AMQP::Protocol::Properties, @payload : Slice(UInt8))
      end

      def initialize(@reserved_1 : UInt16, @exchange : String, @routing_key : String, @mandatory : Bool, @immediate : Bool, @properties : AMQP::Protocol::Properties, payload : String)
        @payload = payload.to_slice
      end

      def id
        [60_u16, 40_u16]
      end

      def sync?
        false
      end

      def has_content?
        true
      end

      def content
        {@properties, @payload}
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        mandatory = bits & (1 << 0) == 1
        immediate = bits & (1 << 1) == 1
        properties = AMQP::Protocol::Properties.new
        payload = ""
        Publish.new(reserved_1, exchange, routing_key, mandatory, immediate, properties, payload)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@exchange)
        io.write_shortstr(@routing_key)
        bits = 0_u8
        bits = bits | (1 << 0) if @mandatory
        bits = bits | (1 << 1) if @immediate
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Publish("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "mandatory: "
        mandatory.inspect(io)
        io << ", "
        io << "immediate: "
        immediate.inspect(io)
        io << ", "
        io << "properties: "
        properties.inspect(io)
        io << ", "
        io << "payload: "
        payload.inspect(io)
        io << ")"
      end
    end

    class Return < Method
      INDEX = 50_u16

      getter reply_code, reply_text, exchange, routing_key, properties, payload

      def initialize(@reply_code : UInt16, @reply_text : String, @exchange : String, @routing_key : String, @properties : Hash(String, AMQP::Protocol::Field), @payload : String)
      end

      def id
        [60_u16, 50_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        reply_code = io.read_short
        raise ::IO::EOFError.new unless reply_code
        reply_text = io.read_shortstr
        raise ::IO::EOFError.new unless reply_text
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        properties = Table.new
        payload = ""
        Return.new(reply_code, reply_text, exchange, routing_key, properties, payload)
      end

      def encode(io)
        io.write_short(@reply_code)
        io.write_shortstr(@reply_text)
        io.write_shortstr(@exchange)
        io.write_shortstr(@routing_key)
      end

      def to_s(io)
        io << "Basic.Return("
        io << "reply_code: "
        reply_code.inspect(io)
        io << ", "
        io << "reply_text: "
        reply_text.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "properties: "
        properties.inspect(io)
        io << ", "
        io << "payload: "
        payload.inspect(io)
        io << ")"
      end
    end

    class Deliver < Method
      INDEX = 60_u16

      getter consumer_tag, delivery_tag, redelivered, exchange, routing_key, properties, payload

      def initialize(@consumer_tag : String, @delivery_tag : UInt64, @redelivered : Bool, @exchange : String, @routing_key : String, @properties : Hash(String, AMQP::Protocol::Field), @payload : String)
      end

      def id
        [60_u16, 60_u16]
      end

      def sync?
        false
      end

      def has_content?
        true
      end

      def content
        {@properties, @payload}
      end

      def self.decode(io)
        consumer_tag = io.read_shortstr
        raise ::IO::EOFError.new unless consumer_tag
        delivery_tag = io.read_longlong
        raise ::IO::EOFError.new unless delivery_tag
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        redelivered = bits & (1 << 0) == 1
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        properties = Table.new
        payload = ""
        Deliver.new(consumer_tag, delivery_tag, redelivered, exchange, routing_key, properties, payload)
      end

      def encode(io)
        io.write_shortstr(@consumer_tag)
        io.write_longlong(@delivery_tag)
        bits = 0_u8
        bits = bits | (1 << 0) if @redelivered
        io.write_octet(bits)
        io.write_shortstr(@exchange)
        io.write_shortstr(@routing_key)
      end

      def to_s(io)
        io << "Basic.Deliver("
        io << "consumer_tag: "
        consumer_tag.inspect(io)
        io << ", "
        io << "delivery_tag: "
        delivery_tag.inspect(io)
        io << ", "
        io << "redelivered: "
        redelivered.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "properties: "
        properties.inspect(io)
        io << ", "
        io << "payload: "
        payload.inspect(io)
        io << ")"
      end
    end

    class Get < Method
      INDEX = 70_u16

      getter reserved_1, queue, no_ack

      def initialize(@reserved_1 : UInt16, @queue : String, @no_ack : Bool)
      end

      def id
        [60_u16, 70_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_short
        raise ::IO::EOFError.new unless reserved_1
        queue = io.read_shortstr
        raise ::IO::EOFError.new unless queue
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        no_ack = bits & (1 << 0) == 1
        Get.new(reserved_1, queue, no_ack)
      end

      def encode(io)
        io.write_short(@reserved_1)
        io.write_shortstr(@queue)
        bits = 0_u8
        bits = bits | (1 << 0) if @no_ack
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Get("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ", "
        io << "queue: "
        queue.inspect(io)
        io << ", "
        io << "no_ack: "
        no_ack.inspect(io)
        io << ")"
      end
    end

    class GetOk < Method
      INDEX = 71_u16

      getter delivery_tag, redelivered, exchange, routing_key, message_count, properties, payload

      def initialize(@delivery_tag : UInt64, @redelivered : Bool, @exchange : String, @routing_key : String, @message_count : UInt32, @properties : Hash(String, AMQP::Protocol::Field), @payload : String)
      end

      def id
        [60_u16, 71_u16]
      end

      def sync?
        true
      end

      def has_content?
        true
      end

      def content
        {@properties, @payload}
      end

      def self.decode(io)
        delivery_tag = io.read_longlong
        raise ::IO::EOFError.new unless delivery_tag
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        redelivered = bits & (1 << 0) == 1
        exchange = io.read_shortstr
        raise ::IO::EOFError.new unless exchange
        routing_key = io.read_shortstr
        raise ::IO::EOFError.new unless routing_key
        message_count = io.read_long
        raise ::IO::EOFError.new unless message_count
        properties = Table.new
        payload = ""
        GetOk.new(delivery_tag, redelivered, exchange, routing_key, message_count, properties, payload)
      end

      def encode(io)
        io.write_longlong(@delivery_tag)
        bits = 0_u8
        bits = bits | (1 << 0) if @redelivered
        io.write_octet(bits)
        io.write_shortstr(@exchange)
        io.write_shortstr(@routing_key)
        io.write_long(@message_count)
      end

      def to_s(io)
        io << "Basic.GetOk("
        io << "delivery_tag: "
        delivery_tag.inspect(io)
        io << ", "
        io << "redelivered: "
        redelivered.inspect(io)
        io << ", "
        io << "exchange: "
        exchange.inspect(io)
        io << ", "
        io << "routing_key: "
        routing_key.inspect(io)
        io << ", "
        io << "message_count: "
        message_count.inspect(io)
        io << ", "
        io << "properties: "
        properties.inspect(io)
        io << ", "
        io << "payload: "
        payload.inspect(io)
        io << ")"
      end
    end

    class GetEmpty < Method
      INDEX = 72_u16

      getter reserved_1

      def initialize(@reserved_1 : String)
      end

      def id
        [60_u16, 72_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        reserved_1 = io.read_shortstr
        raise ::IO::EOFError.new unless reserved_1
        GetEmpty.new(reserved_1)
      end

      def encode(io)
        io.write_shortstr(@reserved_1)
      end

      def to_s(io)
        io << "Basic.GetEmpty("
        io << "reserved_1: "
        reserved_1.inspect(io)
        io << ")"
      end
    end

    class Ack < Method
      INDEX = 80_u16

      getter delivery_tag, multiple

      def initialize(@delivery_tag : UInt64, @multiple : Bool)
      end

      def id
        [60_u16, 80_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        delivery_tag = io.read_longlong
        raise ::IO::EOFError.new unless delivery_tag
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        multiple = bits & (1 << 0) == 1
        Ack.new(delivery_tag, multiple)
      end

      def encode(io)
        io.write_longlong(@delivery_tag)
        bits = 0_u8
        bits = bits | (1 << 0) if @multiple
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Ack("
        io << "delivery_tag: "
        delivery_tag.inspect(io)
        io << ", "
        io << "multiple: "
        multiple.inspect(io)
        io << ")"
      end
    end

    class Reject < Method
      INDEX = 90_u16

      getter delivery_tag, requeue

      def initialize(@delivery_tag : UInt64, @requeue : Bool)
      end

      def id
        [60_u16, 90_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        delivery_tag = io.read_longlong
        raise ::IO::EOFError.new unless delivery_tag
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        requeue = bits & (1 << 0) == 1
        Reject.new(delivery_tag, requeue)
      end

      def encode(io)
        io.write_longlong(@delivery_tag)
        bits = 0_u8
        bits = bits | (1 << 0) if @requeue
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Reject("
        io << "delivery_tag: "
        delivery_tag.inspect(io)
        io << ", "
        io << "requeue: "
        requeue.inspect(io)
        io << ")"
      end
    end

    class RecoverAsync < Method
      INDEX = 100_u16

      getter requeue

      def initialize(@requeue : Bool)
      end

      def id
        [60_u16, 100_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        requeue = bits & (1 << 0) == 1
        RecoverAsync.new(requeue)
      end

      def encode(io)
        bits = 0_u8
        bits = bits | (1 << 0) if @requeue
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.RecoverAsync("
        io << "requeue: "
        requeue.inspect(io)
        io << ")"
      end
    end

    class Recover < Method
      INDEX = 110_u16

      getter requeue

      def initialize(@requeue : Bool)
      end

      def id
        [60_u16, 110_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        requeue = bits & (1 << 0) == 1
        Recover.new(requeue)
      end

      def encode(io)
        bits = 0_u8
        bits = bits | (1 << 0) if @requeue
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Recover("
        io << "requeue: "
        requeue.inspect(io)
        io << ")"
      end
    end

    class RecoverOk < Method
      INDEX = 111_u16

      def initialize()
      end

      def id
        [60_u16, 111_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        RecoverOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Basic.RecoverOk("
        io << ")"
      end
    end

    class Nack < Method
      INDEX = 120_u16

      getter delivery_tag, multiple, requeue

      def initialize(@delivery_tag : UInt64, @multiple : Bool, @requeue : Bool)
      end

      def id
        [60_u16, 120_u16]
      end

      def sync?
        false
      end

      def has_content?
        false
      end

      def self.decode(io)
        delivery_tag = io.read_longlong
        raise ::IO::EOFError.new unless delivery_tag
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        multiple = bits & (1 << 0) == 1
        requeue = bits & (1 << 1) == 1
        Nack.new(delivery_tag, multiple, requeue)
      end

      def encode(io)
        io.write_longlong(@delivery_tag)
        bits = 0_u8
        bits = bits | (1 << 0) if @multiple
        bits = bits | (1 << 1) if @requeue
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Basic.Nack("
        io << "delivery_tag: "
        delivery_tag.inspect(io)
        io << ", "
        io << "multiple: "
        multiple.inspect(io)
        io << ", "
        io << "requeue: "
        requeue.inspect(io)
        io << ")"
      end
    end

  end

  module Tx
    INDEX = 90_u16

    class Select < Method
      INDEX = 10_u16

      def initialize()
      end

      def id
        [90_u16, 10_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        Select.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Tx.Select("
        io << ")"
      end
    end

    class SelectOk < Method
      INDEX = 11_u16

      def initialize()
      end

      def id
        [90_u16, 11_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        SelectOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Tx.SelectOk("
        io << ")"
      end
    end

    class Commit < Method
      INDEX = 20_u16

      def initialize()
      end

      def id
        [90_u16, 20_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        Commit.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Tx.Commit("
        io << ")"
      end
    end

    class CommitOk < Method
      INDEX = 21_u16

      def initialize()
      end

      def id
        [90_u16, 21_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        CommitOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Tx.CommitOk("
        io << ")"
      end
    end

    class Rollback < Method
      INDEX = 30_u16

      def initialize()
      end

      def id
        [90_u16, 30_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        Rollback.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Tx.Rollback("
        io << ")"
      end
    end

    class RollbackOk < Method
      INDEX = 31_u16

      def initialize()
      end

      def id
        [90_u16, 31_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        RollbackOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Tx.RollbackOk("
        io << ")"
      end
    end

  end

  module Confirm
    INDEX = 85_u16

    class Select < Method
      INDEX = 10_u16

      getter nowait

      def initialize(@nowait : Bool)
      end

      def id
        [85_u16, 10_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        bits = io.read_octet
        raise ::IO::EOFError.new unless bits
        nowait = bits & (1 << 0) == 1
        Select.new(nowait)
      end

      def encode(io)
        bits = 0_u8
        bits = bits | (1 << 0) if @nowait
        io.write_octet(bits)
      end

      def to_s(io)
        io << "Confirm.Select("
        io << "nowait: "
        nowait.inspect(io)
        io << ")"
      end
    end

    class SelectOk < Method
      INDEX = 11_u16

      def initialize()
      end

      def id
        [85_u16, 11_u16]
      end

      def sync?
        true
      end

      def has_content?
        false
      end

      def self.decode(io)
        SelectOk.new()
      end

      def encode(io)
      end

      def to_s(io)
        io << "Confirm.SelectOk("
        io << ")"
      end
    end

  end

  class Method
    def self.parse_method(cls_id, meth_id, io)
      case cls_id
      when 10
        case meth_id
        when 10
          Connection::Start.decode(io)
        when 11
          Connection::StartOk.decode(io)
        when 20
          Connection::Secure.decode(io)
        when 21
          Connection::SecureOk.decode(io)
        when 30
          Connection::Tune.decode(io)
        when 31
          Connection::TuneOk.decode(io)
        when 40
          Connection::Open.decode(io)
        when 41
          Connection::OpenOk.decode(io)
        when 50
          Connection::Close.decode(io)
        when 51
          Connection::CloseOk.decode(io)
        when 60
          Connection::Blocked.decode(io)
        when 61
          Connection::Unblocked.decode(io)
        else
          raise FrameError.new("Invalid method index #{cls_id}-#{meth_id}")
        end
      when 20
        case meth_id
        when 10
          Channel::Open.decode(io)
        when 11
          Channel::OpenOk.decode(io)
        when 20
          Channel::Flow.decode(io)
        when 21
          Channel::FlowOk.decode(io)
        when 40
          Channel::Close.decode(io)
        when 41
          Channel::CloseOk.decode(io)
        else
          raise FrameError.new("Invalid method index #{cls_id}-#{meth_id}")
        end
      when 40
        case meth_id
        when 10
          Exchange::Declare.decode(io)
        when 11
          Exchange::DeclareOk.decode(io)
        when 20
          Exchange::Delete.decode(io)
        when 21
          Exchange::DeleteOk.decode(io)
        when 30
          Exchange::Bind.decode(io)
        when 31
          Exchange::BindOk.decode(io)
        when 40
          Exchange::Unbind.decode(io)
        when 51
          Exchange::UnbindOk.decode(io)
        else
          raise FrameError.new("Invalid method index #{cls_id}-#{meth_id}")
        end
      when 50
        case meth_id
        when 10
          Queue::Declare.decode(io)
        when 11
          Queue::DeclareOk.decode(io)
        when 20
          Queue::Bind.decode(io)
        when 21
          Queue::BindOk.decode(io)
        when 50
          Queue::Unbind.decode(io)
        when 51
          Queue::UnbindOk.decode(io)
        when 30
          Queue::Purge.decode(io)
        when 31
          Queue::PurgeOk.decode(io)
        when 40
          Queue::Delete.decode(io)
        when 41
          Queue::DeleteOk.decode(io)
        else
          raise FrameError.new("Invalid method index #{cls_id}-#{meth_id}")
        end
      when 60
        case meth_id
        when 10
          Basic::Qos.decode(io)
        when 11
          Basic::QosOk.decode(io)
        when 20
          Basic::Consume.decode(io)
        when 21
          Basic::ConsumeOk.decode(io)
        when 30
          Basic::Cancel.decode(io)
        when 31
          Basic::CancelOk.decode(io)
        when 40
          Basic::Publish.decode(io)
        when 50
          Basic::Return.decode(io)
        when 60
          Basic::Deliver.decode(io)
        when 70
          Basic::Get.decode(io)
        when 71
          Basic::GetOk.decode(io)
        when 72
          Basic::GetEmpty.decode(io)
        when 80
          Basic::Ack.decode(io)
        when 90
          Basic::Reject.decode(io)
        when 100
          Basic::RecoverAsync.decode(io)
        when 110
          Basic::Recover.decode(io)
        when 111
          Basic::RecoverOk.decode(io)
        when 120
          Basic::Nack.decode(io)
        else
          raise FrameError.new("Invalid method index #{cls_id}-#{meth_id}")
        end
      when 90
        case meth_id
        when 10
          Tx::Select.decode(io)
        when 11
          Tx::SelectOk.decode(io)
        when 20
          Tx::Commit.decode(io)
        when 21
          Tx::CommitOk.decode(io)
        when 30
          Tx::Rollback.decode(io)
        when 31
          Tx::RollbackOk.decode(io)
        else
          raise FrameError.new("Invalid method index #{cls_id}-#{meth_id}")
        end
      when 85
        case meth_id
        when 10
          Confirm::Select.decode(io)
        when 11
          Confirm::SelectOk.decode(io)
        else
          raise FrameError.new("Invalid method index #{cls_id}-#{meth_id}")
        end
      else
        raise FrameError.new("Invalid class index #{cls_id}")
      end
    end
  end
end

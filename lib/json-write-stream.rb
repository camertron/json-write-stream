# encoding: UTF-8

require 'json'
require 'json-write-stream/yielding'
require 'json-write-stream/stateful'

class JsonWriteStream
  class << self
    def from_stream(stream)
      if block_given?
        yield YieldingWriter.new(stream)
      else
        StatefulWriter.new(stream)
      end
    end

    def open(file)
      handle = File.open(file, 'w')

      if block_given?
        yield writer = YieldingWriter.new(handle)
        writer.close
      else
        StatefulWriter.new(handle)
      end
    end
  end
end

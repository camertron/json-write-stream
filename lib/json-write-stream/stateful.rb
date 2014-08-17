# encoding: UTF-8

class JsonWriteStream
  class NotAnObjectError < StandardError; end
  class NotAnArrayError < StandardError; end
  class EndOfStreamError < StandardError; end

  class StatefulWriter
    attr_reader :stream, :index, :stack, :closed
    alias :closed? :closed

    def initialize(stream)
      @stream = stream
      @index = 0
      @stack = []
      @closed = false
      after_initialize
    end

    def after_initialize
    end

    def write_object(*args)
      check_eos
      current.write_object(*args) if current
      stack.push(StatefulObjectWriter.new(stream))
    end

    def write_array(*args)
      check_eos
      current.write_array(*args) if current
      stack.push(StatefulArrayWriter.new(stream))
    end

    def write_key_value(*args)
      check_eos
      current.write_key_value(*args)
    end

    def write_element(*args)
      check_eos
      current.write_element(*args)
    end

    def close_object
      if in_object?
        stack.pop.close
        current.increment if current
        increment
      else
        raise NotAnObjectError, 'not currently writing an object.'
      end
    end

    def close_array
      if in_array?
        stack.pop.close
        current.increment if current
        increment
      else
        raise NotAnArrayError, 'not currently writing an array.'
      end
    end

    def close
      until stack.empty?
        if in_object?
          close_object
        else
          close_array
        end
      end

      stream.close
      @closed = true
      nil
    end

    def in_object?
      current ? current.is_object? : false
    end

    def in_array?
      current ? current.is_array? : false
    end

    def eos?
      (stack.size == 0 && index > 0) || closed?
    end

    protected

    def check_eos
      if eos?
        raise EndOfStreamError, 'end of stream.'
      end
    end

    def current
      stack.last
    end

    def escape(str)
      JSON.generate([str])[1..-2]
    end

    def write_comma
      stream.write(',') if index > 0
    end

    def increment
      @index += 1
    end
  end

  class StatefulObjectWriter < StatefulWriter
    def after_initialize
      stream.write('{')
    end

    # prep work (array is written afterwards)
    def write_array(key)
      write_comma
      increment
      write_key(key)
      stream.write(':')
    end

    # prep work (object is written afterwards)
    def write_object(key)
      write_comma
      increment
      write_key(key)
      stream.write(':')
    end

    def write_key_value(key, value)
      write_comma
      increment
      write_key(key)
      stream.write(":#{escape(value)}")
    end

    def close
      stream.write('}')
    end

    def is_object?
      true
    end

    def is_array?
      false
    end

    private

    def write_key(key)
      case key
        when String
          stream.write(escape(key))
        else
          raise ArgumentError, "'#{key}' must be a string"
      end
    end
  end

  class StatefulArrayWriter < StatefulWriter
    def after_initialize
      stream.write('[')
    end

    def write_element(element)
      write_comma
      increment
      stream.write(escape(element))
    end

    # prep work
    def write_array
      write_comma
      increment
    end

    # prep work
    def write_object
      write_comma
      increment
    end

    def close
      stream.write(']')
    end

    def is_object?
      false
    end

    def is_array?
      true
    end
  end
end

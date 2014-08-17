json-write-stream
=================

An easy, streaming way to generate JSON.

## Installation

`gem install json-write-stream`

## Usage

```ruby
require 'json-write-stream'
```

### Examples for the Impatient

There are two types of JSON write stream: one that uses blocks and yield to delimit arrays and objects, and one that's purely stateful. Here are two examples that produce the same output:

Yielding:

```ruby
stream = StringIO.new
JsonWriteStream.from_stream(stream) do |writer|
  writer.write_object do |obj_writer|
    obj_writer.write_key_value('foo', 'bar')
    obj_writer.write_array('baz') do |arr_writer|
      arr_writer.write_element('goo')
    end
  end
end
```

Stateful:

```ruby
stream = StringIO.new
writer = JsonWriteStream.from_stream(stream)
writer.write_object
writer.write_key_value('foo', 'bar')
writer.write_array('baz')
writer.write_element('goo')
writer.close  # automatically adds closing punctuation for all nested types
```

Output:

```ruby
stream.string # => {"foo":"bar","baz":["goo"]}
```

## Requirements

No external requirements.

## Running Tests

`bundle exec rake` should do the trick. You can also run `bundle exec rspec`, which does the same thing.

## Authors

* Cameron C. Dutro: http://github.com/camertron

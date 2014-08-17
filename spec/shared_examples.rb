# encoding: UTF-8

shared_examples 'a json stream' do
  it 'handles a simple array' do
    check_roundtrip(['abc'])
  end

  it 'handles a simple object' do
    check_roundtrip({ 'foo' => 'bar' })
  end

  it 'handles one level of array nesting' do
    check_roundtrip([['def'],'abc'])
    check_roundtrip(['abc',['def']])
  end

  it 'handles one level of object nesting' do
    check_roundtrip({ 'foo' => { 'bar' => 'baz' } })
  end

  it 'handles one level of mixed nesting' do
    check_roundtrip({ 'foo' => ['bar', 'baz'] })
    check_roundtrip([{ 'foo' => 'bar' }])
  end

  it 'handles multiple levels of mixed nesting' do
    check_roundtrip({'foo' => ['bar', { 'baz' => 'moo', 'gaz' => ['doo'] }, 'kal'], 'jim' => ['jill', ['john']] })
    check_roundtrip(['foo', { 'bar' => 'baz', 'moo' => ['gaz', ['jim', ['jill']], 'jam'] }])
  end
end

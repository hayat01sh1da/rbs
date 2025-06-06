require_relative "test_helper"

class RactorSingletonTest < Test::Unit::TestCase
  include TestHelper

  testing "singleton(::Ractor)"

  def test_aref
    if_ruby("3.4"...) do
      assert_send_type(
        "(Symbol) -> untyped",
        Ractor, :[], :foo
      )
    end
  end

  def test_arefeq
    if_ruby("3.4"...) do
      assert_send_type(
        "(Symbol, Integer) -> Integer",
        Ractor, :[]=, :foo, 1
      )
    end
  end

  def test_count
    assert_send_type "() -> Integer",
                     Ractor, :count
  end

  def test_current
    assert_send_type "() -> Ractor",
                     Ractor, :current
  end

  def test_main
    assert_send_type "() -> Ractor",
                     Ractor, :main
  end

  def test_main?
    if_ruby("3.4"...) do
      assert_send_type "() -> bool", Ractor, :main?
    end
  end

  def test_make_shareable
    assert_send_type "(String) -> String",
                     Ractor, :make_shareable, 'foo'
    assert_send_type "(String, copy: true) -> String",
                     Ractor, :make_shareable, 'foo', copy: true
    assert_send_type "(String, copy: false) -> String",
                     Ractor, :make_shareable, 'foo', copy: false
    assert_send_type "(String, copy: nil) -> String",
                     Ractor, :make_shareable, 'foo', copy: nil
  end

  def test_new
    # TODO: it raises an error because the proc is not isolated
    # assert_send_type '() { () -> untyped } -> Ractor',
    #                  Ractor, :new do end
  end

  def test_receive
    Ractor.current.send 42
    assert_send_type "() -> Integer",
                     Ractor, :receive
  end

  def test_recv
    Ractor.current.send 42
    assert_send_type "() -> Integer",
                     Ractor, :recv
  end

  def test_receive_if
    omit "Ractor.receive_if is not implemented" if RUBY_VERSION >= "3.5"

    Ractor.current.send 42
    assert_send_type "() { (Integer) -> bool } -> Integer",
                     Ractor, :receive_if do |n| n == 42 end
  end

  def test_select
    omit "Ractor#yield is not implemented" if RUBY_VERSION >= "3.5"

    r1 = Ractor.new {|r| loop { Ractor.yield 42 } }
    r2 = Ractor.new {|r| loop { Ractor.yield 43 } }

    assert_send_type "(Ractor) -> [Ractor, Integer]",
                     Ractor, :select, r1
    assert_send_type "(Ractor, Ractor) -> [Ractor, Integer]",
                     Ractor, :select, r1, r2

    Ractor.current.send 42
    assert_send_type "(Ractor) -> [:receive, Integer]",
                     Ractor, :select, Ractor.current

    Ractor.new(Ractor.current) { |r| r.take }
    assert_send_type "(Ractor, yield_value: untyped) -> [:yield, nil]",
                     Ractor, :select, Ractor.current, yield_value: 'foo'

    assert_send_type "(Ractor, move: bool) -> [Ractor, Integer]",
                     Ractor, :select, r1, move: true
  end

  def test_shareable?
    assert_send_type "(untyped) -> true",
                     Ractor, :shareable?, 42
    assert_send_type "(untyped) -> false",
                     Ractor, :shareable?, []
  end

  def test_store_if_absent
    assert_send_type(
      "(Symbol) { (nil) -> true } -> true",
      Ractor, :store_if_absent, :test_store_if_absent, &->(_x) { true }
    )
  end

  def test_yield
    omit "Ractor#yield is not implemented" if RUBY_VERSION >= "3.5"

    Ractor.new(Ractor.current) { |r| loop { r.take } }

    assert_send_type "(Integer) -> untyped",
                     Ractor, :yield, 42
    assert_send_type "(Integer, move: true) -> untyped",
                     Ractor, :yield, 42, move: true
    assert_send_type "(Integer, move: false) -> untyped",
                     Ractor, :yield, 42, move: false
  end
end

class RactorInstanceTest < Test::Unit::TestCase
  include TestHelper

  testing "::Ractor"

  def test_aref
    omit "Accessing ractor local storage" if RUBY_VERSION >= "3.5"

    r = Ractor.new {}
    r['foo'] = 'bar'
    assert_send_type "(String) -> untyped",
                     r, :[], 'foo'
    assert_send_type "(Symbol) -> untyped",
                     r, :[], :foo
  end

  def test_aset
    omit "Accessing ractor local storage" if RUBY_VERSION >= "3.5"

    r = Ractor.new {}
    assert_send_type "(String, String) -> String",
                     r, :[]=, 'foo', 'bar'
    assert_send_type "(Symbol, Integer) -> Integer",
                     r, :[]=, :foo, 42
  end

  def test_close_incoming
    omit "Ractor#close_incoming is not implemented" if RUBY_VERSION >= "3.5"
    
    r = Ractor.new {}
    assert_send_type "() -> bool",
                     r, :close_incoming
  end

  def test_close_outgoing
    omit "Ractor#close_outgoing is not implemented" if RUBY_VERSION >= "3.5"

    r = Ractor.new {}
    assert_send_type "() -> bool",
                     r, :close_outgoing
  end

  def test_inspect
    assert_send_type "() -> String",
                     Ractor.current, :inspect
  end

  def test_name
    unnamed = Ractor.new {}
    named = Ractor.new(name: 'foo') {}
    assert_send_type "() -> nil",
                     unnamed, :name
    assert_send_type "() -> String",
                     named, :name
  end

  def test_send
    r = Ractor.new { sleep }

    assert_send_type "(Integer) -> Ractor",
                     r, :send, 42
    assert_send_type "(Integer, move: true) -> Ractor",
                     r, :send, 42, move: true
    assert_send_type "(Integer, move: nil) -> Ractor",
                     r, :send, 42, move: nil
  end

  def test_take
    omit "Ractor#take is not implemented" if RUBY_VERSION >= "3.5"

    r = Ractor.new { 42 }

    assert_send_type "() -> Integer",
                     r, :take
  end

  def test_to_s
    assert_send_type "() -> String",
                     Ractor.current, :to_s
  end
end

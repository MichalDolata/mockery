defmodule Mockery.HelperTest do
  use ExUnit.Case, async: true
  import Mockery

  defmodule TestDummy1 do
    use Mockery.Helper, module: Dummy
  end

  defmodule TestDummy2 do
    use Mockery.Helper, module: Dummy

    global_mock Dummy, [fun2: 0], do: 50
  end

  describe "defaults" do
    test "when arity == 0" do
      assert Dummy.fun1() == TestDummy1.fun1()
      assert Dummy.fun2() == TestDummy1.fun2()
    end

    test "when arity > 0" do
      assert Dummy.ar(1) == TestDummy1.ar(1)
      assert Dummy.ar(1, "a") == TestDummy1.ar(1, "a")
    end
  end

  describe "global mock" do
    test "unchanged function" do
      assert TestDummy1.fun1() == 1
      assert TestDummy2.fun1() == 1
    end

    test "overriden function" do
      assert TestDummy1.fun2() == 2
      assert TestDummy2.fun2() == 50
    end

    test "respects nonglobal mock" do
      mock(Dummy, :fun2, 100)

      assert TestDummy1.fun2() == 100
      assert TestDummy2.fun2() == 100
    end

    test "respects nonglobal mock with function of same arity" do
      mock(Dummy, :fun2, fn-> "x" end)

      assert TestDummy1.fun2() == "x"
      assert TestDummy2.fun2() == "x"
    end

    test "test raise on function with bad arity" do
      mock(Dummy, :fun2, &to_string/1)

      assert_raise(
        Mockery.Error,
        "function used for mock should have same arity as original",
        fn -> TestDummy2.fun2() end
      )
    end
  end
end
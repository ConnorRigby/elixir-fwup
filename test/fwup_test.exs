defmodule FwupTest do
  use ExUnit.Case
  doctest Fwup

  alias Fwup.TestSupport.Fixtures

  test "apply" do
    {:ok, fw} = Fixtures.create_firmware("test_apply")
    dev = Path.join(Path.dirname(fw), "test_apply.img")
    assert {:ok, pid} = Fwup.apply(dev, "complete", fw)
    assert_receive {:fwup, {:progress, 100}}
    assert_receive {:fwup, {:ok, 0, ""}}
  end
end

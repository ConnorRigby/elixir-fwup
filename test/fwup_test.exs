defmodule FwupTest do
  use ExUnit.Case
  doctest Fwup

  alias Fwup.TestSupport.Fixtures

  test "apply" do
    {:ok, fw} = Fixtures.create_firmware("test_apply")
    dev = Path.join(Path.dirname(fw), "test_apply.img")
    assert :ok = Fwup.apply(dev, "complete", fw)
  end
end

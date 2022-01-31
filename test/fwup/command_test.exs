defmodule Fwup.CommandTest do
  use ExUnit.Case
  alias Fwup.TestSupport.Fixtures

  test "metadata" do
    {:ok, fw_path} = Fixtures.create_firmware("test")
    {:ok, metadata} = Fwup.Command.metadata(fw_path)

    assert metadata == %{
             "architecture" => "x86_64",
             "author" => "me",
             "creation-date" => "1970-01-01T00:00:00Z",
             "description" => "D ",
             "platform" => "platform",
             "product" => "nerves-hub",
             "uuid" => "f46925cb-7c7b-5aae-10fb-a93c09941b60",
             "version" => "1.0.0"
           }
  end

  test "metadata converts keys to atoms" do
    {:ok, fw_path} = Fixtures.create_firmware("test")
    {:ok, metadata} = Fwup.Command.metadata(fw_path, keys_to_atoms: true)

    assert metadata == %{
             architecture: "x86_64",
             author: "me",
             creation_date: "1970-01-01T00:00:00Z",
             description: "D ",
             platform: "platform",
             product: "nerves-hub",
             uuid: "f46925cb-7c7b-5aae-10fb-a93c09941b60",
             version: "1.0.0"
           }
  end
end

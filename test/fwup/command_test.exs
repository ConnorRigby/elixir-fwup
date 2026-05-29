defmodule Fwup.CommandTest do
  use ExUnit.Case
  alias Fwup.TestSupport.Fixtures

  test "metadata" do
    {:ok, fw_path} = Fixtures.create_firmware("test")
    {:ok, metadata} = Fwup.Command.metadata(fw_path)

    assert metadata["architecture"] == "x86_64"
    assert metadata["author"] == "me"
    assert metadata["creation-date"] == "1970-01-01T00:00:00Z"
    assert metadata["description"] == "D "
    assert metadata["platform"] == "platform"
    assert metadata["product"] == "nerves-hub"
    assert metadata["version"] == "1.0.0"

    # See fwup 1.14.0 release notes for UUID change
    assert metadata["uuid"] == "dfd76641-2d09-5a0b-043e-536d28640b29" or
             metadata["uuid"] == "f46925cb-7c7b-5aae-10fb-a93c09941b60"

    # fwup 1.15.0 reports nicknames
    assert metadata["nickname"] in [nil, "street-spy"]
  end

  test "metadata converts keys to atoms" do
    {:ok, fw_path} = Fixtures.create_firmware("test")
    {:ok, metadata} = Fwup.Command.metadata(fw_path, keys_to_atoms: true)

    assert metadata.architecture == "x86_64"
    assert metadata.author == "me"
    assert metadata.creation_date == "1970-01-01T00:00:00Z"
    assert metadata.description == "D "
    assert metadata.platform == "platform"
    assert metadata.product == "nerves-hub"
    assert metadata.version == "1.0.0"

    assert metadata.uuid == "dfd76641-2d09-5a0b-043e-536d28640b29" or
             metadata.uuid == "f46925cb-7c7b-5aae-10fb-a93c09941b60"

    # fwup 1.15.0 reports nicknames
    assert metadata[:nickname] in [nil, "street-spy"]
  end

  test "all metadata keys can be converted to atoms" do
    {:ok, fw_path} = Fixtures.create_firmware("test")
    {:ok, atom_metadata} = Fwup.Command.metadata(fw_path, keys_to_atoms: true)
    {:ok, string_metadata} = Fwup.Command.metadata(fw_path)

    num_atom_keys = length(Map.keys(atom_metadata))
    num_string_keys = length(Map.keys(string_metadata))

    assert num_atom_keys == num_string_keys
  end
end

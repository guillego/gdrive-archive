defmodule GdriveArchive.File do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "files" do
    field :parent, :string
    field :name, :string
    field :mime_type, :string
    field :size, :integer
    field :checksum, :string
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:id, :parent, :name, :mime_type, :size, :checksum])
    |> validate_required([:id, :name, :mime_type, :size, :checksum])
  end
end

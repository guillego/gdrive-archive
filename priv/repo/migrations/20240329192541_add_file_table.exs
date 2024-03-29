defmodule GdriveArchive.Repo.Migrations.AddFileTable do
  use Ecto.Migration

    def change do
      create table(:files, primary_key: false) do
        add :id, :text, primary_key: true
        add :parent, :text
        add :name, :text
        add :mime_type, :text
        add :size, :integer
        add :checksum, :text
      end
    end

end

defmodule GdriveArchive.Repo do
  use Ecto.Repo,
    otp_app: :gdrive_archive,
    adapter: Ecto.Adapters.SQLite3
end

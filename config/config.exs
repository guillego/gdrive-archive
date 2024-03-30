import Config

config :gdrive_archive,
  ecto_repos: [GdriveArchive.Repo]

config :gdrive_archive, GdriveArchive.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "_storage/db.sqlite3"

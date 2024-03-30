defmodule GdriveArchive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  defp load_google_application_credentials() do
    credentials =
      "GOOGLE_APPLICATION_CREDENTIALS"
      |> System.fetch_env!()
      |> File.read!()
      |> Jason.decode!()

    credentials
  end

  @impl true
  def start(_type, _args) do
    Logger.info("Starting supervision tree")
    # GdriveArchive.Gdrive.list_all_files()

    source = {:service_account, load_google_application_credentials(), scopes: ["https://www.googleapis.com/auth/drive"]}

       children = [
      GdriveArchive.Repo,
      {Goth, name: GdriveArchive.Goth, source: source},
      # {Task, fn -> GdriveArchive.Indexer.execute() end}
      # Starts a worker by calling: GdriveArchive.Worker.start_link(arg)
      # {GdriveArchive.Worker, arg}
      # {Task, fn -> GdriveArchive.Gdrive.list_all_files() end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GdriveArchive.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

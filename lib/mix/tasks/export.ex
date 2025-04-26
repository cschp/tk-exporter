defmodule Mix.Tasks.Export do
  require Logger

  use Mix.Task

  @shortdoc "Exports data from Tavern-Keeper"
  def run(_) do
    user_id = System.get_env("USER_ID")
    cookie = System.get_env("TK_COOKIE")

    if is_nil(user_id) || is_nil(cookie) do
      Logger.error "USER_ID and TK_COOKIE required!"
    else
      Application.ensure_all_started(:tk_export)
      TkExporter.export(user_id, cookie)
    end
  end
end

defmodule Mix.Tasks.Compile.Dart do
  require Logger
  @dart System.find_executable("dart") || raise("Dart not found")
  @target Application.app_dir(:saucy, ["priv", "sassy", "bin", "sassy.dart"])

  def run(_opts) do
    Logger.info("Compiling dart executable")

    case System.cmd(@dart, ["compile", "exe", @target]) do
      {info, 0} ->
        Logger.info(info)
        :ok

      {error, status_code} ->
        Logger.warning("""
        failed compiling dart file:
        #{inspect(error)}
        """)

        System.halt(status_code)
    end
  end
end

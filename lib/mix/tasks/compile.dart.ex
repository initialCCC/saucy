defmodule Mix.Tasks.Compile.Dart do
  require Logger
  @dart System.find_executable("dart") || raise("Dart not found")
  @target Application.app_dir(:saucy, ["priv", "sassy", "bin", "sassy.dart"])

  def run(_opts) do
    with false <- already_compiled?(),
         {_info, 0} <- System.cmd(@dart, ["compile", "exe", @target]) do
      :ok
    else
      {error, status_code} ->
        Logger.warning("failed compiling dart file: #{inspect(error)}")
        System.halt(status_code)

      _ ->
        :ok
    end
  end

  def already_compiled? do
    Application.app_dir(:saucy, ["priv/sassy/bin/sassy.exe"]) |> File.exists?()
  end
end

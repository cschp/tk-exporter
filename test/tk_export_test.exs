defmodule TkExportTest do
  use ExUnit.Case
  doctest TkExport

  setup do
    # Set up test environment
    Application.put_env(:tk_export, :base_url, "http://localhost:4000")
    Application.put_env(:tk_export, :sleep_delay, 0)
    Application.put_env(:tk_export, :max_retries, 1)
    Application.put_env(:tk_export, :retry_delay, 0)
    Application.put_env(:tk_export, :output_dir, "test_output")
    Application.put_env(:tk_export, :parallel_requests, 1)

    on_exit(fn ->
      # Clean up test output directory
      File.rm_rf!("test_output")
    end)
  end

  test "export creates output directory" do
    TkExport.export("test_user", "test_cookie")
    assert File.exists?("test_output")
  end

  test "export handles API errors gracefully" do
    # This test assumes the API is not available
    result = TkExport.export("test_user", "test_cookie")
    assert is_list(result)
  end
end

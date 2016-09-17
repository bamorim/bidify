Path.wildcard("test/utils/*.ex")
|> Enum.each(&Code.load_file(&1))
ExUnit.start()

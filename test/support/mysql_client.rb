# ホストに mysqldump / mysql が無ければ、docker compose の mysql コンテナ内のクライアントを使う
unless ENV['PATH'].to_s.split(File::PATH_SEPARATOR).any? { |dir| File.executable?(File.join(dir, 'mysqldump')) }
  ENV['PATH'] = [File.join(TEST_ROOT, 'bin'), ENV['PATH']].join(File::PATH_SEPARATOR)
end

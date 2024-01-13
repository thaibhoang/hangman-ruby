require 'json'
f = File.readlines('save.txt')
p f[1]
p JSON.load(f[0])
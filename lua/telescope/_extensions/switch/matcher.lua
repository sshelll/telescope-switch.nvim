local builtin = {}

builtin.go_test = {
    name = 'go test',
    from = '(.*).go$',
    to = '%1_test.go'
}

builtin.go_impl = {
    name = 'go impl',
    from = '(.*)_test.go$',
    to = '%1.go'
}

builtin.rust_mod = {
    name = "rust mod.rs",
    from = "(.*)/(.*)rs$",
    to = "%1/mod.rs",
}

builtin.rust_mod_file = {
    name = "rust mod file",
    from = "(.*)/mod.rs$",
    to = "%1/*.rs",
}

return builtin

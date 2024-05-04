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

return builtin

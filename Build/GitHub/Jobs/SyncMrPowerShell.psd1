@{
    'runs-on' = 'ubuntu-latest'
    steps = @(
        @{
            name = 'Check out repository'
            uses = 'actions/checkout@main'
        }
        @{
            name = 'Use Websocket Action'
            uses = 'PowerShellWeb/Websocket@main'
            id = 'WebSocket'
        }
    )
}

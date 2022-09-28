@{
    LogColors = @{
        Timestamp = 'DarkGray'
          Message = 'Gray'

          Error = 'Red'
        Warning = 'Yellow'
           Info = 'White'

        Verbose = 'DarkGreen'
          Debug = 'DarkCyan'

        Progress = 'Magenta'
    }

    LogTypes = @{
        Information = 1
           Progress = 1

          Error = 3
        Warning = 2
           Info = 1

        Verbose = -10
          Debug = -20
    }

    IgnoreStrings = @(
        'Preparing modules for first use.'
    )
}

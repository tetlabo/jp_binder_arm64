def _radiant_command(port):
    return [
        "/usr/local/bin/R",
        "-e",
        f"options(radiant.jupyter=TRUE); radiant.data::launch(package='radiant', host='0.0.0.0', port={port}, run=FALSE)",
    ]


c.ServerProxy.servers = {
    "code": {
        "command": [
            "code-server",
            "--locale",
            "ja",
            "--disable-telemetry",
            "--auth",
            "none",
            "--socket",
            "{unix_socket}",
        ],
        "timeout": 30,
        "launcher_entry": {
            "enabled": True,
            "icon_path": "/usr/lib/code-server/lib/vscode/extensions/npm/images/code.svg",
            "title": "Visual Studio Code",
        },
        "unix_socket": "/tmp/code-server",
    },
    "radiant": {
        "command": _radiant_command,
        "timeout": 30,
        "launcher_entry": {
            "title": "Radiant",
            "icon_path": "/home/rstudio/.local/radiant/logo200.svg",
        },
    },
}

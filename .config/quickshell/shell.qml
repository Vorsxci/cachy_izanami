import Quickshell
import "bar"
import "utils-panel"
import "center-panel"
import "tasks-panel"
import "media-panel"
import "run-panel"

ShellRoot {
    Bar {
        id: bar
    }

    UtilsPanel {
        networkService: bar.networkSvc
    }

    CenterPanel {}

    TasksPanel {}

    MediaPanel {}

    RunPanel{}
}

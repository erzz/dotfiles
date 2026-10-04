# Scratchpad Indicator

A compact red `SCRATCH` label for the Omarchy bar. It appears while the
Hyprland `special:scratchpad` workspace is active/open on a monitor. Hidden
scratchpad windows do not keep it visible, and the widget does not display a
window count.

Enable the plugin and place it beside the numbered workspace list:

```sh
omarchy plugin enable erzz.scratchpad-indicator
omarchy bar move erzz.scratchpad-indicator --after omarchy.workspaces
```

On a vertical bar, the label rotates to fit alongside the vertically stacked
workspace list.

Requires Omarchy's Quickshell bar and Hyprland's `Quickshell.Hyprland` module.
The widget uses Omarchy's `BarWidget`, `Color`, and `Style` helpers and has no
additional dependencies.

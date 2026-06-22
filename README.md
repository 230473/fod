# FOD Practices

I compile my projects using

```bash
fpc -FE../data/ -FU../data/ PROGRAM_NAME.pas
```

to move all compilation outputs from `src` to `data`, keeping it clean.

- FE: Redirects the executable file.
- FU: Redirects compiled units (.ppu and .o files).

This is abstracted to a VSCode task in the `.vscode/tasks.json` to be shown in the building commands menu with `Ctrl + Shift + B` command.

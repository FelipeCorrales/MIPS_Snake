# Snake in MIPS
This was made as a project for college
I did not tested it thoroughly because NixOS decided that java was going to crash every 5 minutes
I think there is a bug with the apples, however, I due to time constrains I will not be fixing it, also, for some reason (Nix) I cannot run MARS at full speed, meaning that I have to test the game at super slow speeds
This is not very optimized either, memory usage is fine, instruction count is bad
Tried to comment most things that were not straightforward, however, don't ask me to explain splashes

![screenshot](/screenshot.png)

# How to run
This must program be ran through MARS, in order to see the display enable the `Bitmap Display`, you can find it in Tools->Bitmap Display.

These are the correct settings for the Bitmap Display:
```
Unit Width in Pixels: 8
Unit Height in Pixels: 8
Display Width in Pixels: 512
Display Height in Pixels: 256
Base address for display: 0x10010000 (static data)
```

In order to play the game enable the `Keyboard and Display MMIO Simulator`, similarly, you can find it in Tools->Keyboard and Display MMIO Simulator. The game should now recognize your inputs.

## Controls
- Space: Used to start the game and continue after a game over
- W: Move up
- A: Move left
- S: Move down
- D: Move right
- ESC: Stops the game at any point

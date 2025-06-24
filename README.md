# Snake in MIPS
This was made as a project for college

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

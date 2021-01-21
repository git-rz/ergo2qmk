# Ergo2qmk

Converts source code experted from [Oryx (the Ergodox-EZ configurator)](https://configure.ergodox-ez.com/ergodox-ez/layouts/ABaJR/latest/3) such that it can be used for the Corne, Redox wireless, and the dactyl manuform.

This includes the following features:
- Key map
- LED map (Corne only)
- Macros

# Instructions
1. Copy my keymap on [Oryx](https://configure.ergodox-ez.com/ergodox-ez/layouts/ABaJR/latest/3)
1. Modify it to suit your fancy.
2. Use at least one per-key RGB value per layer. Nothing else has been tested. Corne only.
2. Download the source for your map and extract keymap.c
2. Edit ergo2qmk.pl, following the instructions therein. Notably, set the variables `board` and `yourKmDirName`.
2. Ensure `QMK_HOME` is exported in your environment.
2. #include "ergo2qmk.h" in your keymap.c, for redox, or:
2. Copy all my keymap files from the example directory for Corne. You can modify them later, but mine will take care of setting the proper lights on layer switch.
2. Run `ergo2qmk.pl < ergodox-source/keymap.c` to create ergo2qmk.h in your keymap dir.
2. Remove any definition from your keymap.c that is now defined in ergo2qmk.h
3. `qmk compile`

## Corne Key Map
The Corne fits neatly within an Ergodox. For the purpose of mapping keys, the following rules apply:

- The three main rows of the Corne map to the middle three Ergodox rows.
- The three thumb keys of the Corne map to the larger keys of the Ergodox thumb cluster, plus the smaller key that's adjacent to the thumb cluster.
- The first thumb key (70 from the diagram below) maps to the innermost corne thumb key
- The second thumb key (71) maps to the middle corne thumb key

The above mapping is a compromise, because a better alignment physically would have been to use only one Ergodox thumb key and two from the bottom row.
This was changed when Redox support was added. When switching between Redox and Ergodox, the most natural and efficient mapping is to use both the thumb keys.

## Redox Key Map
The Redox is almost exactly the same as the Ergodox. The following mappings are made:

- top middle column keys are ignored.


## LED Map
```
Corne
!-------+-----+-----+-----+-----+-----+ 2 1 0     27-29 +-----+-----+-----+-----+-----+-------!
|  24 a | 23  | 18  | 17  | 10  | 9   | x x x     x x x | 36  | 37  | 44  | 45  | 50  |  51 a |
!-------+-----+-----+-----x-----x-----|                 |-----x-----x-----+-----+-----+-------!
|  25 b | 22  | 19  | 16  | 11  | 8   |  back      back | 35  | 38  | 43  | 46  | 49  |  52 b |
!-------+-----+-----+-----x-----x-----| 3 4 5     32-30 |-----x-----x-----+-----+-----+-------!
|  26 c | 21  | 20  | 15  | 12  | 7   | y y y     y y y | 34  | 39  | 42  | 47  | 48  |  53 c |
'-------+-----+-----+-----+-----+-----|-----+     +-----+-----+-----+-----+-----+-----+-------'
                          | 14  | 13 e| 6  d|     ! 33 d| 40 e| 41  |
                           -----------------'     '-----------------'
Ergodox-ez
.---------------------------------------------. .---------------------------------------------.
|       | 28 a| 27 b| 26 c| 25 y| 24 x|       | !       | 0 x | 1 y | 2 c | 3 b | 4 a |       |
!-------+-----+-----+-----+-----+-------------! !-------+-----+-----+-----+-----+-----+-------!
|       | 33  | 32  | 31  | 30  | 29  |       | !       | 5   | 6   | 7   | 8   | 9   |       |
!-------+-----+-----+-----x-----x-----!       ! !       !-----x-----x-----+-----+-----+-------!
|       | 38  | 37  | 36  | 35  | 34  |-------! !-------! 10  | 11  | 12  | 13  | 14  |       |
!-------+-----+-----+-----x-----x-----!       ! !       !-----x-----x-----+-----+-----+-------!
|       | 43  | 42  | 41  | 40  | 39  |       | !       | 15  | 16  | 17  | 18  | 19  |       |
'-------+-----+-----+-----+-----+-------------' '-------------+-----+-----+-----+-----+-------'
|       | 47 d| 46  | 45 e| 44  |                             ! 20  | 21 e| 22  | 23 d|      |
 '------------------------------'                             '------------------------------'
```

The numbers in the diagram above are in the order of the LED programming for each board. This
tool will take care of the translation, using all the same rules as the key map above, but
with a few needed exceptions:

 | Ergodox LED | Corne       |
 | ----------- | ----------- |
 | 0           |  right top 3 backlight 27,28,29 |
 | 1           |  right bottom 3 backlight 30,31,32 |
 | 24          |  left  top 3 backlight 0,1,2 |
 | 25          |  left  bottom 3 backlight 3,4,5 |
 | 26-28       |  left outermost column. see diagram where mapping is noted by a b c|
 | 2-4         |  right outermost column. see diagram where mapping is noted by a b c|
 | 23          |  right thumb 33 |
 | 21          |  right thumb 40 |
 | 47          |  left thumb 6 |
 | 45          |  left thumb 13 |
 | 22          | unused |
 | 46          | unused |

tl;dr - shift the Corne diagram such that it overlaps with the Ergodox. Then use the letters
to match the remaining keys where Corne has LEDs but Ergodox doesn't.

This arrangement maximizes the overlap of keys and lights.

## Keymap Reference
The following diagrams are useful if you want to alter the mapping in the script.

### Ergodox:
```
       "0",  "1",  "2",  "3",  "4",  "5",        "6",        "7",        "8",  "9", "10", "11", "12", "13",
      "14", "15", "16", "17", "18", "19",       "20",       "21",       "22", "23", "24", "25", "26", "27",
      "28", "29", "30", "31", "32", "33",                               "34", "35", "36", "37", "38", "39",
      "40", "41", "42", "43", "44", "45",       "46",       "47",       "48", "49", "50", "51", "52", "53",
      "54", "55", "56", "57", "58",                                     "59", "60", "61", "62", "63",
                                          "64", "65",       "66", "67",
                                                "68",       "69",
                                    "70", "71", "72",       "73", "74", "75"
```

### Corne:
```
       "0",  "1",  "2",  "3",  "4",  "5",                                "6",  "7",  "8",  "9", "10", "11",
      "12", "13", "14", "15", "16", "17",                               "18", "19", "20", "21", "22", "23",
      "24", "25", "26", "27", "28", "29",                               "30", "31", "32", "33", "34", "35",
                              "36", "37", "38",                   "39", "40", "41"
```

### Redox:
```
       "0",  "1",  "2",  "3",  "4",  "5",                                "6",  "7",  "8",  "9", "10", "11",
      "12", "13", "14", "15", "16", "17",          "18", "19",          "20", "21", "22", "23", "24", "25",
      "26", "27", "28", "29", "30", "31",          "32", "33",          "34", "35", "36", "37", "38", "39",
      "40", "41", "42", "43", "44", "45",    "46", "47", "48", "49",    "50", "51", "52", "53", "54", "55",
      "56", "57", "58", "59",    "60",       "61", "62", "63", "64",       "65",    "66", "67", "68", "69"

```
### Manuform 5x6:
```
       "0",  "1",  "2",  "3",  "4",  "5",                                "6",  "7",  "8",  "9", "10", "11",
      "12", "13", "14", "15", "16", "17",                               "18", "19", "20", "21", "22", "23",
      "24", "25", "26", "27", "28", "29",                               "30", "31", "32", "33", "34", "35",
      "36", "37", "38", "39", "40", "41",                               "42", "43", "44", "45", "46", "47",
                  "48", "49",                                                       "50", "51",
                                  "52", "53",                        "54", "55",
                                    "56", "57",                     "58", "59",
                                    "60", "61",                     "62", "63"

```

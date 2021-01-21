#!env perl
use 5.010;
use Text::Balanced qw(extract_bracketed);

# Set the board to generate. must be in the %boards map.
$board = 'redox_w';
$board = 'crkbd';
$board = 'handwired/dactyl_manuform/5x6';

# keymap dir in which to place he output
$yourKmDirName = "git-rz";

# Maps the Corne LEDs in the order of the wires, to the Ergodox LED numbering.
# The actual led numbers on the corne snake around the back then up and down the front moving from inside to outside..
# Don't mind the shape of these numbers.. you'll be misled. the only thing orienting about them is that the first half
# are for the left hand.


%boards = (
  crkbd => {
    keymap => "$yourKmDirName",
    leds => [
      24, 24, 24, 25, 25, 25,

      47, 39, 34, 29, 30, 35,
      40, 45, 44, 41, 36, 31,
      32, 37, 42, 43, 38, 33,
                     28, 27, 26,

       0,  0,  0,  1,  1,  1,

      23, 15, 10,  5,  6, 11,
      16, 21, 20, 17, 12,  7,
       8, 13, 18, 19, 14,  9,
    4, 3, 2
    ],
    keylookup => [
      14, 15, 16, 17, 18, 19,                         22, 23, 24, 25, 26, 27,
      28, 29, 30, 31, 32, 33,                         34, 35, 36, 37, 38, 39,
      40, 41, 42, 43, 44, 45,                         48, 49, 50, 51, 52, 53,
                    58,  71,  70,                  75,  74,  59
    ]
  },
  redox_w => {
    keymap => "$yourKmDirName",
    leds => "nope",
    keylookup => [
      0,  1,  2,  3,  4,  5,                           8,  9, 10, 11, 12, 13,
      14, 15, 16, 17, 18, 19,          20, 21,        22, 23, 24, 25, 26, 27,
      28, 29, 30, 31, 32, 33,          46, 47,        34, 35, 36, 37, 38, 39,
      40, 41, 42, 43, 44, 45,      68, 72, 69, 73,    48, 49, 50, 51, 52, 53,
      54, 55, 56, 57,    58,       70, 71, 74, 75,      59,   60, 61, 62, 63
    ]
  },
  "handwired/dactyl_manuform/5x6" => {
    keymap => "$yourKmDirName",
    leds => "nope",
    keylookup => [
      0,  1,  2,  3,  4,  5,                           8,  9, 10, 11, 12, 13,
      14, 15, 16, 17, 18, 19,                         22, 23, 24, 25, 26, 27,
      28, 29, 30, 31, 32, 33,                         34, 35, 36, 37, 38, 39,
      40, 41, 42, 43, 44, 45,                         48, 49, 50, 51, 52, 53,
              56, 57,                                         60, 61,
                       71, 70,                     75, 74,
                       58, 68,                     69, 59,
                       65, 72,                     73, 66
    ]
  }
);

sub parseLayer {
  my ($layer, $board) = @_;
  my @keycodes = ();
  my $i = 0;
  while ($layer) {
    last if $i++ > 500;
    if ($layer =~ /^([^(]*?)(,|\s*$)/) {
        push @keycodes, $1;
        $layer =~ s/^\Q$1\E\s*,?\s*//;
    } else {
        my ($ext, $pre);
        ($ext, $layer, $pre) = extract_bracketed($layer,'()','[^()]+');
        push @keycodes, "$pre$ext";
        $layer =~ s/^\s*,\s*//;
    }
  }
  my @desire = ();

  foreach (@{$boards{$board}->{keylookup}}) {
    push @desire, "$keycodes[$_]";
  }
  return @desire;
}

$ledmaps = "const uint8_t PROGMEM ledmap[][DRIVER_LED_TOTAL][3] = {\n";
$keymaps = "const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {\n";

my $enum = "";
my $pru = "";

my $hasleds = "ARRAY" eq ref($boards{$board}->{leds});

while (<>) {
  chomp;
  $ledfound = true if /PROGMEM ledmap/;
  $ledfound = false if /;/;

  $kmfound = true if /PROGMEM keymaps/;
  $kmfound = false if /;/;

  $kchfound = "t" if /enum custom_keycodes/;
  $kchfound = false if /;/;

  $prufound = "t" if /bool process_record_user/;
  $prufound = false if /^}/;

  if ($prufound eq "t") {
    $pru .= "$_\n";
  }

  if ($kchfound eq "t") {
    $enum .= "$_\n";
  }

  if ($kmfound) {
    if (m/^ *\[(\d+)\] = LAYOUT.*/) {
      $layerNum = $1;
      $layer = "";
      next;
    }
    if ( /^ *\),\s*$/ ) {
      my @layerMap = parseLayer($layer, $board);
      $keymaps .= "[$layerNum] = LAYOUT( " . join(",", @layerMap) . "),\n";
    } else {
      $layer .= $_;
    }
  }

  if ($ledfound && $hasleds) {
    if (m/^ *\[(\d+)\] = \{(.*)\}.*/) {
      $cap = $2;
      @hsvlist = split(/, /, $cap, -1);
      $ledmaps .= "    [$1] = { ";
      foreach (@{$boards{$board}->{leds}}) {
        $ledmaps .= "$hsvlist[$_], ";
      }
      $ledmaps .= " },\n";
    }
  }
}

$out = "$ENV{'QMK_HOME'}/keyboards/$board/keymaps/$boards{$board}->{keymap}/ergo2qmk.h";
say "Writing $out";
open(KH, '>', "$out") or die $!;
print KH "$enum};\n$pru\n}\n\n";
print KH "$keymaps};\n\n";
print KH "$ledmaps};\n" if $hasleds;
close(KH);

print "Done.\n";

#include QMK_KEYBOARD_H
#define EZ_SAFE_RANGE SAFE_RANGE
#define WEBUSB_PAIR KC_TRNS
#include "ergo2qmk.h"


#ifdef RGBLIGHT_ENABLE
//Following line allows macro to read current RGB settings
extern rgblight_config_t rgblight_config;
#endif

extern uint8_t is_master;

int RGB_current_mode;

void set_layer_color(int layer) {
/*
  if (layer == 0) {
    rgb_matrix_mode(RGB_MATRIX_JELLYBEAN_RAINDROPS);
    return;
  }
  rgblight_mode(RGBLIGHT_MODE_STATIC_LIGHT);
*/


  for (int i = 0; i < DRIVER_LED_TOTAL; i++) {
    HSV hsv = {
      .h = pgm_read_byte(&ledmap[layer][i][0]),
      .s = pgm_read_byte(&ledmap[layer][i][1]),
      .v = pgm_read_byte(&ledmap[layer][i][2]),
    };
    int effectiveI = i;
    if (isLeftHand && i>26) {
      break;
    };
    if (!isLeftHand && i>26) {
      effectiveI = i - 27;
    }
    if (!hsv.h && !hsv.s && !hsv.v) {
        rgb_matrix_set_color( effectiveI, 0, 0, 0 );
    } else {
        RGB rgb = hsv_to_rgb( hsv );
        float f = (float)rgb_matrix_config.hsv.v / UINT8_MAX;
        rgb_matrix_set_color( effectiveI, f * rgb.r, f * rgb.g, f * rgb.b );
    }
  }
}

void keyboard_post_init_user(void) {
  rgb_matrix_enable();
  matrix_init_kb();
}

/*
uint32_t layer_state_set_user(uint32_t state) {
  uint8_t layer = biton32(state);
  set_layer_color(layer);
  return state;
}
*/


void rgb_matrix_indicators_user(void) {
  uint8_t layer = biton32(layer_state);
  uint8_t leds = host_keyboard_leds();

  if (layer == 3) {
    if (!(leds & (1 << USB_LED_NUM_LOCK))) {
      layer = 8;
    }
  }
  set_layer_color(layer);
}

void matrix_init_user(void) {
#ifdef RGBLIGHT_ENABLE
  RGB_current_mode = rgblight_config.mode;
#endif
  //SSD1306 OLED init, make sure to add #define SSD1306OLED in config.h
#ifdef SSD1306OLED
  iota_gfx_init(!has_usb());   // turns on the display
#endif
}

//SSD1306 OLED update loop, make sure to add #define SSD1306OLED in config.h
#ifdef SSD1306OLED

// When add source files to SRC in rules.mk, you can use functions.
const char *read_layer_state(void);
const char *read_logo(void);
void set_keylog(uint16_t keycode, keyrecord_t *record);
const char *read_keylog(void);
const char *read_keylogs(void);

// const char *read_mode_icon(bool swap);
const char *read_host_led_state(void);
// void set_timelog(void);
// const char *read_timelog(void);

void matrix_scan_user(void) {
  iota_gfx_task();
}

void matrix_render_user(struct CharacterMatrix *matrix) {
  if (is_master) {
char buffer[5];
sprintf(buffer, "%d", DRIVER_LED_TOTAL);
    // If you want to change the display of OLED, you need to change here
    matrix_write_ln(matrix, read_layer_state());
    //matrix_write_ln(matrix, read_keylog());
    //matrix_write_ln(matrix, read_keylogs());
    //matrix_write_ln(matrix, read_mode_icon(keymap_config.swap_lalt_lgui));
    matrix_write_ln(matrix, read_host_led_state());
matrix_write_ln(matrix, buffer);
    //matrix_write_ln(matrix, read_timelog());
  } else {
    matrix_write(matrix, read_logo());
  }
}

void matrix_update(struct CharacterMatrix *dest, const struct CharacterMatrix *source) {
  if (memcmp(dest->display, source->display, sizeof(dest->display))) {
    memcpy(dest->display, source->display, sizeof(dest->display));
    dest->dirty = true;
  }
}

void iota_gfx_task_user(void) {
  struct CharacterMatrix matrix;
  matrix_clear(&matrix);
  matrix_render_user(&matrix);
  matrix_update(&display, &matrix);
}
#endif//SSD1306OLED

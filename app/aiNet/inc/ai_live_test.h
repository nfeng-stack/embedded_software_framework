#ifndef AI_LIVE_TEST_H
#define AI_LIVE_TEST_H

#ifdef LIVE_TEST_MODE

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LIVE_TEST_MAX_SAMPLES       4000
#define LIVE_TEST_BATCH_SIZE        50
#define LIVE_TEST_INFER_WINDOW      200
#define LIVE_TEST_MIN_FILE_BYTES    4096
#define LIVE_TEST_CSV_LINE_SIZE     128
#define LIVE_TEST_BACK_CONFIRM_MS   100
#define LIVE_TEST_I2C_ERR_THRESHOLD 10
#define LIVE_TEST_TICK_PERIOD       5
#define LIVE_TEST_LED_TIMER_PERIOD  50

#define BUTTON_SELECT    0
#define BUTTON_CONFIRM   1
#define BUTTON_BACK      2
#define BUTTON_EMERGENCY 3

typedef enum {
    STATE_IDLE = 0,
    STATE_ACT_SEL,
    STATE_READY,
    STATE_RECORDING,
} live_test_state_t;

typedef enum {
    MODE_ADL = 0,
    MODE_FALL,
} live_test_mode_t;

typedef enum {
    LED_OFF = 0,
    LED_IDLE,
    LED_ADL_SEL,
    LED_FALL_SEL,
    LED_READY,
    LED_RECORDING,
} live_test_led_t;

extern volatile uint8_t btn_pending[4];

extern const char *live_test_adl_names[6];
extern const char *live_test_fall_names[6];
extern const char *live_test_adl_labels[6];
extern const char *live_test_fall_labels[6];

void live_test_init(void);
void live_test_task(void *param);

#ifdef __cplusplus
}
#endif

#endif /* LIVE_TEST_MODE */
#endif /* AI_LIVE_TEST_H */

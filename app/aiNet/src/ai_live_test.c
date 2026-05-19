#ifdef LIVE_TEST_MODE

#define LOG_TAG "LIVETEST"
#define LOG_LVL ELOG_LVL_DEBUG
#include "elog.h"

#include "ai_live_test.h"
#include "hal.h"
#include "osal.h"
#include "fatfs_service.h"
#include "framework_interrupts.h"
#include "../../mpu6050/inc/driver_mpu6050_basic.h"
#include "../../mpu6050/inc/driver_mpu6050.h"
#include "../../cdc_msc/usb_state.h"
#include <string.h>
#include <stdio.h>

/* ─── 活动名称定义 ─── */
const char *live_test_adl_names[6] = {
    "a01", "a02", "a03", "a04", "a05", "a06"
};
const char *live_test_fall_names[6] = {
    "f01", "f02", "f03", "f04", "f05", "f06"
};
const char *live_test_adl_labels[6] = {
    "Walk", "SitQuick", "StandQuick", "BendPickup", "LieDown", "Jump"
};
const char *live_test_fall_labels[6] = {
    "Forward", "Backward", "Lateral", "SlipChair", "BedFall", "Trip"
};

/* ─── 按钮标志 (ISR 写入) ─── */
volatile uint8_t btn_pending[4] = {0, 0, 0, 0};

/* ─── 全局上下文 ─── */
static struct {
    live_test_state_t state;
    live_test_mode_t  mode;
    int               act_idx;
    int               cur_trial_display;
    int               trial_counts[12];

    volatile uint32_t write_idx;
    volatile uint16_t batch_count;
    volatile uint8_t  auto_stop;
    volatile uint8_t  i2c_err_count;

    uint32_t back_press_tick;
    uint8_t  back_press_count;
    uint32_t led_tick;
    live_test_led_t led_state;

    osal_semaphore_t sem;
    osal_task_t      task;
    mpu6050_handle_t *mpu_handle;

    uint8_t  *write_buf;
    char     *csv_line;
} g_ctx;

/* ─── 私有函数前向声明 ─── */
static void live_test_state_recording(void);
static void live_test_led_update(void);
static void live_test_led_set(live_test_led_t state);
static int  live_test_mkdir_p(const char *path);
static int  live_test_scan_trials(void);
static int  live_test_recording_begin(void);
static void live_test_recording_finish(uint8_t save);
static void live_test_emergency_reset(void);
static void live_test_process_buttons(void);
static const char *live_test_get_activity_name(void);
static const char *live_test_get_mode_dir(void);
static void live_test_uart_display(void);

/* ══════════════════════════════════════════════════════════════
 *  MPU6050 中断回调 (IRQ 41 = PA15 EXTI15)
 * ══════════════════════════════════════════════════════════════ */
static void live_test_mpu6050_isr_cb(void)
{
    hal_clean_it();
    osal_sem_release(g_ctx.sem);
}

/* ══════════════════════════════════════════════════════════════
 *  量化: 物理单位 → uint8 [0,255]
 * ══════════════════════════════════════════════════════════════ */
static void live_test_quantize_sample(const float acc[3], const float gyro[3],
                                       uint8_t out[6])
{
    const float acc_scale = 255.0f / 32.0f;
    const float gry_scale = 255.0f / 4000.0f;

    for (int j = 0; j < 3; j++) {
        float v = acc[j];
        if (v < -16.0f) v = -16.0f;
        else if (v > 16.0f) v = 16.0f;
        int val = (int)((v + 16.0f) * acc_scale + 0.5f);
        if (val < 0) val = 0;
        else if (val > 255) val = 255;
        out[j] = (uint8_t)val;
    }
    for (int j = 0; j < 3; j++) {
        float v = gyro[j];
        if (v < -2000.0f) v = -2000.0f;
        else if (v > 2000.0f) v = 2000.0f;
        int val = (int)((v + 2000.0f) * gry_scale + 0.5f);
        if (val < 0) val = 0;
        else if (val > 255) val = 255;
        out[3 + j] = (uint8_t)val;
    }
}

/* ══════════════════════════════════════════════════════════════
 *  MPU6050 初始化 (LIVE_TEST 模式简化版)
 * ══════════════════════════════════════════════════════════════ */
static int live_test_mpu6050_init(void)
{
    uint8_t res;

    res = mpu6050_basic_init(MPU6050_ADDRESS_AD0_LOW);
    if (res != 0) {
        log_e("MPU6050 basic_init failed: %u", res);
        return -1;
    }
    log_i("MPU6050 basic_init OK");

    framework_interrupts_register_handler(41, live_test_mpu6050_isr_cb);

    if (mpu6050_basic_get_handle(&g_ctx.mpu_handle) != 0 || g_ctx.mpu_handle == NULL) {
        log_e("Failed to get MPU6050 handle");
        return -1;
    }

    res = mpu6050_set_interrupt_pin_type(g_ctx.mpu_handle, MPU6050_PIN_TYPE_PUSH_PULL);
    if (res != 0) { log_e("set interrupt pin type failed"); return -1; }

    res = mpu6050_set_interrupt_level(g_ctx.mpu_handle, MPU6050_PIN_LEVEL_LOW);
    if (res != 0) { log_e("set interrupt level failed"); return -1; }

    res = mpu6050_set_interrupt_read_clear(g_ctx.mpu_handle, MPU6050_BOOL_TRUE);
    if (res != 0) { log_e("set interrupt read_clear failed"); return -1; }

    res = mpu6050_set_interrupt_latch(g_ctx.mpu_handle, MPU6050_BOOL_TRUE);
    if (res != 0) { log_e("set interrupt latch failed"); return -1; }

    hal_gpio_init_int();

    {
        float probe_acc[3], probe_gyro[3];
        res = mpu6050_basic_read(probe_acc, probe_gyro);
        if (res != 0) {
            log_e("MPU6050 probe read failed: %u", res);
            return -1;
        }
    }
    log_i("MPU6050 probe read OK");

    return 0;
}

/* ══════════════════════════════════════════════════════════════
 *  递归 mkdir -p (FATFS 不支持递归, 逐级创建每个 '/' 分隔的组件)
 * ══════════════════════════════════════════════════════════════ */
static int live_test_mkdir_p(const char *path)
{
    char tmp[128];
    size_t len = strlen(path);
    if (len >= sizeof(tmp)) return -1;
    memcpy(tmp, path, len + 1);

    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';
            if (tmp[0] != '\0') {
                fatfs_err_t err = fatfs_service_mkdir(tmp);
                log_d("mkdir_p: %s → %d", tmp, (int)err);
                if (err != FATFS_OK && err != FATFS_ERR_EXISTS) {
                    *p = '/';
                    return -1;
                }
            }
            *p = '/';
        }
    }
    if (tmp[0] != '\0') {
        fatfs_err_t err = fatfs_service_mkdir(tmp);
        log_d("mkdir_p: %s → %d", tmp, (int)err);
        if (err != FATFS_OK && err != FATFS_ERR_EXISTS) {
            return -1;
        }
    }
    return 0;
}

/* ══════════════════════════════════════════════════════════════
 *  扫描已有 trial 编号 (防断电覆盖旧文件)
 * ══════════════════════════════════════════════════════════════ */
static int live_test_scan_trials(void)
{
    memset(g_ctx.trial_counts, 0, sizeof(g_ctx.trial_counts));

    for (int m = 0; m < 2; m++) {
        const char *mode_dir = (m == 0) ? "adl" : "fall";
        const char **names = (m == 0) ? live_test_adl_names : live_test_fall_names;
        int base = m * 6;
        for (int a = 0; a < 6; a++) {
            /* 先检查目录是否存在, 不存在则跳过 (无 trial) */
            char dir_path[64];
            snprintf(dir_path, sizeof(dir_path), "/data/live_test/%s/%s",
                     mode_dir, names[a]);
            if (!fatfs_service_exists(dir_path)) {
                g_ctx.trial_counts[base + a] = 0;
                log_d("%s not found, trials=0", dir_path);
                continue;
            }

            int max_r = 0;
            for (int r = 1; r <= 128; r++) {
                char path[80];
                snprintf(path, sizeof(path),
                         "/data/live_test/%s/%s/R%02d.csv", mode_dir, names[a], r);
                fatfs_fileinfo_t info;
                if (fatfs_service_stat(path, &info) == FATFS_OK) {
                    if (info.size >= LIVE_TEST_MIN_FILE_BYTES) {
                        max_r = r;
                    } else {
                        log_w("%s exists but too small (%lu bytes), ignoring",
                              path, (unsigned long)info.size);
                    }
                }
            }
            g_ctx.trial_counts[base + a] = max_r;
            log_i("%s/%s: %d existing trials", mode_dir, names[a], max_r);
        }
    }
    return 0;
}

/* ══════════════════════════════════════════════════════════════
 *  LED 状态切换
 * ══════════════════════════════════════════════════════════════ */
static void live_test_led_set(live_test_led_t state)
{
    g_ctx.led_state = state;
    g_ctx.led_tick = 0;
    hal_gpio_led_audio_off();
    log_d("LED state → %d", (int)state);
}

static void live_test_led_update(void)
{
    g_ctx.led_tick++;

    switch (g_ctx.led_state) {
    case LED_OFF:
        hal_gpio_led_audio_off();
        break;

    case LED_IDLE: {
        uint32_t period = 1000 / LIVE_TEST_LED_TIMER_PERIOD;
        if (g_ctx.led_tick % period < period / 2)
            hal_gpio_led_audio_on();
        else
            hal_gpio_led_audio_off();
        break;
    }

    case LED_ADL_SEL: {
        uint32_t period = 500 / LIVE_TEST_LED_TIMER_PERIOD;
        if (g_ctx.led_tick % period < period / 2)
            hal_gpio_led_audio_on();
        else
            hal_gpio_led_audio_off();
        break;
    }

    case LED_FALL_SEL: {
        uint32_t period = 200 / LIVE_TEST_LED_TIMER_PERIOD;
        if (g_ctx.led_tick % period < period / 2)
            hal_gpio_led_audio_on();
        else
            hal_gpio_led_audio_off();
        break;
    }

    case LED_READY: {
        uint32_t period = 1500 / LIVE_TEST_LED_TIMER_PERIOD;
        uint32_t phase = g_ctx.led_tick % period;
        if (phase < 50 || (phase >= 100 && phase < 150) || (phase >= 200 && phase < 250))
            hal_gpio_led_audio_on();
        else
            hal_gpio_led_audio_off();
        break;
    }

    case LED_RECORDING:
        hal_gpio_led_audio_on();
        break;
    }
}

/* ══════════════════════════════════════════════════════════════
 *  辅助函数
 * ══════════════════════════════════════════════════════════════ */
static const char *live_test_get_mode_dir(void)
{
    return (g_ctx.mode == MODE_ADL) ? "adl" : "fall";
}

static const char *live_test_get_activity_name(void)
{
    return (g_ctx.mode == MODE_ADL)
        ? live_test_adl_names[g_ctx.act_idx]
        : live_test_fall_names[g_ctx.act_idx];
}

static const char *live_test_get_activity_label(void)
{
    return (g_ctx.mode == MODE_ADL)
        ? live_test_adl_labels[g_ctx.act_idx]
        : live_test_fall_labels[g_ctx.act_idx];
}

static void live_test_uart_display(void)
{
    const char *state_str = "???";
    switch (g_ctx.state) {
    case STATE_IDLE:      state_str = "IDLE";      break;
    case STATE_ACT_SEL:   state_str = "ACT_SEL";   break;
    case STATE_READY:     state_str = "READY";     break;
    case STATE_RECORDING: state_str = "RECORDING"; break;
    }

    log_i("━━━ LIVE TEST ━━━");
    log_i("State: %s  Mode: %s  Act: %s(%s)  Trial: %d",
          state_str,
          (g_ctx.mode == MODE_ADL) ? "ADL" : "FALL",
          live_test_get_activity_name(),
          live_test_get_activity_label(),
          g_ctx.cur_trial_display);
}

/* ══════════════════════════════════════════════════════════════
 *  按钮处理 (在 task 中轮询)
 * ══════════════════════════════════════════════════════════════ */
static void live_test_process_buttons(void)
{
    /* SELECT (PC0) */
    if (btn_pending[BUTTON_SELECT]) {
        btn_pending[BUTTON_SELECT] = 0;
        switch (g_ctx.state) {
        case STATE_IDLE:
            g_ctx.mode = (g_ctx.mode == MODE_ADL) ? MODE_FALL : MODE_ADL;
            log_i("Mode toggled → %s", (g_ctx.mode == MODE_ADL) ? "ADL" : "FALL");
            break;
        case STATE_ACT_SEL:
            g_ctx.act_idx = (g_ctx.act_idx + 1) % 6;
            log_i("Activity → %s (%s)", live_test_get_activity_name(),
                  live_test_get_activity_label());
            break;
        default:
            break;
        }
    }

    /* CONFIRM (PC1) */
    if (btn_pending[BUTTON_CONFIRM]) {
        btn_pending[BUTTON_CONFIRM] = 0;
        switch (g_ctx.state) {
        case STATE_IDLE:
            g_ctx.state = STATE_ACT_SEL;
            g_ctx.act_idx = 0;
            live_test_led_set(LED_ADL_SEL);
            log_i("→ ACT_SEL (mode=%s)", (g_ctx.mode == MODE_ADL) ? "ADL" : "FALL");
            break;
        case STATE_ACT_SEL: {
            int base = (int)g_ctx.mode * 6;
            g_ctx.cur_trial_display = g_ctx.trial_counts[base + g_ctx.act_idx] + 1;
            g_ctx.state = STATE_READY;
            live_test_led_set(LED_READY);
            log_i("→ READY (trial %d)", g_ctx.cur_trial_display);
            break;
        }
        case STATE_READY:
            if (live_test_recording_begin() == 0) {
                g_ctx.state = STATE_RECORDING;
                live_test_led_set(LED_RECORDING);
                log_i("→ RECORDING (trial %d)", g_ctx.cur_trial_display);
            }
            break;
        case STATE_RECORDING:
            live_test_recording_finish(1);
            g_ctx.state = STATE_READY;
            live_test_led_set(LED_READY);
            log_i("→ READY (STOP+SAVE, trial %d)", g_ctx.cur_trial_display);
            break;
        }
    }

    /* BACK (PB3) - 录制中需二次确认 */
    if (btn_pending[BUTTON_BACK]) {
        btn_pending[BUTTON_BACK] = 0;
        uint32_t now = osal_tick_get();
        switch (g_ctx.state) {
        case STATE_ACT_SEL:
            live_test_led_set(LED_IDLE);
            g_ctx.state = STATE_IDLE;
            log_i("→ IDLE (back from ACT_SEL)");
            break;
        case STATE_READY:
            g_ctx.state = STATE_ACT_SEL;
            live_test_led_set((g_ctx.mode == MODE_ADL) ? LED_ADL_SEL : LED_FALL_SEL);
            log_i("→ ACT_SEL (back from READY)");
            break;
        case STATE_RECORDING:
            if (g_ctx.back_press_count == 0 ||
                (int32_t)(now - g_ctx.back_press_tick) > LIVE_TEST_BACK_CONFIRM_MS) {
                g_ctx.back_press_tick = now;
                g_ctx.back_press_count = 1;
                log_w("CANCEL: press BACK again to confirm discard");
            } else {
                g_ctx.back_press_count = 0;
                live_test_recording_finish(0);
                g_ctx.state = STATE_READY;
                live_test_led_set(LED_READY);
                log_i("→ READY (CANCEL, trial discarded)");
            }
            break;
        default:
            break;
        }
    }

    /* EMERGENCY (PD2) */
    if (btn_pending[BUTTON_EMERGENCY]) {
        btn_pending[BUTTON_EMERGENCY] = 0;
        if (g_ctx.state == STATE_RECORDING) {
            log_e("EMERGENCY abort during recording!");
        }
        live_test_emergency_reset();
        log_i("→ IDLE (EMERGENCY reset)");
    }
}

/* ══════════════════════════════════════════════════════════════
 *  录制开始
 * ══════════════════════════════════════════════════════════════ */
static int live_test_recording_begin(void)
{
    if (usb_state_is_connected()) {
        log_e("USB is connected, cannot start recording");
        return -1;
    }

    {
        uint32_t total_kb = 0, free_kb = 0;
        if (fatfs_service_status(&total_kb, &free_kb) == FATFS_OK) {
            if (free_kb < 1024) {
                log_e("Disk nearly full: %lu KB free", (unsigned long)free_kb);
                return -1;
            }
        }
    }

    /* 探头测试 I2C 通路 */
    {
        float dummy[3];
        if (mpu6050_basic_read(dummy, dummy + 0) != 0) {
            log_e("MPU6050 probe read failed, cannot start");
            return -1;
        }
    }

    g_ctx.write_idx = 0;
    g_ctx.batch_count = 0;
    g_ctx.auto_stop = 0;
    g_ctx.i2c_err_count = 0;
    g_ctx.back_press_count = 0;

    /* 启用 DATA_READY 中断 */
    uint8_t res = mpu6050_set_interrupt(g_ctx.mpu_handle,
                                         MPU6050_INTERRUPT_DATA_READY,
                                         MPU6050_BOOL_TRUE);
    if (res != 0) {
        log_e("Failed to enable DATA_READY interrupt: %u", res);
        return -1;
    }

    log_i("Recording started: mode=%s act=%s trial=%d",
          live_test_get_mode_dir(),
          live_test_get_activity_name(),
          g_ctx.cur_trial_display);
    return 0;
}

/* ══════════════════════════════════════════════════════════════
 *  录制结束 (save=1 写文件, save=0 丢弃)
 * ══════════════════════════════════════════════════════════════ */
static void live_test_recording_finish(uint8_t save)
{
    mpu6050_set_interrupt(g_ctx.mpu_handle,
                          MPU6050_INTERRUPT_DATA_READY,
                          MPU6050_BOOL_FALSE);

    log_i("Recording stopped: samples=%lu save=%d",
          (unsigned long)g_ctx.write_idx, (int)save);

    if (!save || g_ctx.write_idx == 0) {
        log_w("Discarding recording data");
        return;
    }

    if (usb_state_is_connected()) {
        log_e("USB connected, cannot write file");
        return;
    }

    /* 写 R??.csv */
    char path[80];
    snprintf(path, sizeof(path), "/data/live_test/%s/%s/R%02d.csv",
             live_test_get_mode_dir(),
             live_test_get_activity_name(),
             g_ctx.cur_trial_display);

    /* 写入前兜底: 递归确保父目录存在 */
    {
        char dir_path[64];
        snprintf(dir_path, sizeof(dir_path), "/data/live_test/%s/%s",
                 live_test_get_mode_dir(), live_test_get_activity_name());
        if (!fatfs_service_exists(dir_path)) {
            log_i("Dir not found, mkdir -p %s", dir_path);
            if (live_test_mkdir_p(dir_path) != 0) {
                log_e("mkdir -p %s failed", dir_path);
                return;
            }
            fatfs_service_sync();
            log_i("mkdir -p %s OK", dir_path);
        }
    }

    int32_t fh = fatfs_service_open(path, FATFS_MODE_WRITE);
    if (fh < 0) {
        log_e("Cannot create %s: %ld", path, (long)fh);
        return;
    }

    uint32_t written = 0;
    for (uint32_t i = 0; i < g_ctx.write_idx; i++) {
        uint8_t *row = &g_ctx.write_buf[i * 6];
        int len = snprintf(g_ctx.csv_line, LIVE_TEST_CSV_LINE_SIZE,
                           "%u,%u,%u,%u,%u,%u\n",
                           (unsigned)row[0], (unsigned)row[1], (unsigned)row[2],
                           (unsigned)row[3], (unsigned)row[4], (unsigned)row[5]);
        if (len > 0 && len < LIVE_TEST_CSV_LINE_SIZE) {
            int32_t wret = fatfs_service_write(fh, g_ctx.csv_line, (uint32_t)len);
            if (wret == (int32_t)len) {
                written++;
            } else {
                log_e("Write error at row %lu: %ld", (unsigned long)i, (long)wret);
                break;
            }
        }
    }

    fatfs_err_t close_err = fatfs_service_close(fh);
    if (close_err == FATFS_OK && written == g_ctx.write_idx) {
        int base = (int)g_ctx.mode * 6;
        g_ctx.trial_counts[base + g_ctx.act_idx]++;
        log_i("Saved %s (%lu rows)", path, (unsigned long)written);
        fatfs_service_sync();
    } else {
        log_e("Write incomplete: %lu/%lu rows, close=%d",
              (unsigned long)written, (unsigned long)g_ctx.write_idx, (int)close_err);
    }
}

/* ══════════════════════════════════════════════════════════════
 *  紧急复位
 * ══════════════════════════════════════════════════════════════ */
static void live_test_emergency_reset(void)
{
    mpu6050_set_interrupt(g_ctx.mpu_handle,
                          MPU6050_INTERRUPT_DATA_READY,
                          MPU6050_BOOL_FALSE);

    g_ctx.write_idx = 0;
    g_ctx.batch_count = 0;
    g_ctx.auto_stop = 0;
    g_ctx.back_press_count = 0;
    g_ctx.mode = MODE_ADL;
    g_ctx.act_idx = 0;
    g_ctx.state = STATE_IDLE;

    live_test_led_set(LED_IDLE);
}

/* ══════════════════════════════════════════════════════════════
 *  状态机
 * ══════════════════════════════════════════════════════════════ */
static void live_test_state_recording(void)
{
    float acc[3], gyro[3];
    uint8_t reg;

    if (mpu6050_basic_read(acc, gyro) != 0) {
        g_ctx.i2c_err_count++;
        if (g_ctx.i2c_err_count >= LIVE_TEST_I2C_ERR_THRESHOLD) {
            log_e("I2C error threshold reached, auto-stopping");
            mpu6050_set_interrupt(g_ctx.mpu_handle,
                                  MPU6050_INTERRUPT_DATA_READY,
                                  MPU6050_BOOL_FALSE);
            g_ctx.state = STATE_READY;
            live_test_led_set(LED_READY);
        }
        return;
    }

    mpu6050_get_interrupt_status(g_ctx.mpu_handle, &reg);
    (void)reg;

    g_ctx.i2c_err_count = 0;

    uint8_t sample[6];
    live_test_quantize_sample(acc, gyro, sample);

    if (g_ctx.write_idx >= LIVE_TEST_MAX_SAMPLES) {
        mpu6050_set_interrupt(g_ctx.mpu_handle,
                              MPU6050_INTERRUPT_DATA_READY,
                              MPU6050_BOOL_FALSE);
        log_i("Auto-stop at max samples (%lu)", (unsigned long)g_ctx.write_idx);
        live_test_recording_finish(1);
        g_ctx.state = STATE_READY;
        live_test_led_set(LED_READY);
        return;
    }

    memcpy(&g_ctx.write_buf[g_ctx.write_idx * 6], sample, 6);
    g_ctx.write_idx++;
    g_ctx.batch_count++;

    if (g_ctx.write_idx == 200) {
        log_i("First 200 samples collected (1.0s), window ready");
    }

    if (g_ctx.batch_count % 50 == 0 && g_ctx.write_idx >= 200) {
        log_d("Samples: %lu", (unsigned long)g_ctx.write_idx);
    }
}

/* ══════════════════════════════════════════════════════════════
 *  主任务
 * ══════════════════════════════════════════════════════════════ */
void live_test_task(void *param)
{
    (void)param;

    log_i("=== Live Test Task Started ===");

    g_ctx.state = STATE_IDLE;
    g_ctx.mode = MODE_ADL;
    g_ctx.act_idx = 0;
    g_ctx.cur_trial_display = 1;
    live_test_led_set(LED_IDLE);

    live_test_uart_display();

    while (1) {
        live_test_led_update();

        osal_err_t wait_ret = osal_sem_take(g_ctx.sem, LIVE_TEST_LED_TIMER_PERIOD);

        live_test_process_buttons();

        if (g_ctx.state == STATE_RECORDING && wait_ret == 0) {
            live_test_state_recording();
        }
    }
}

/* ══════════════════════════════════════════════════════════════
 *  初始化入口
 * ══════════════════════════════════════════════════════════════ */
void live_test_init(void)
{
    log_i("=== Live Test Init ===");
    log_i("MAX_SAMPLES=%d BATCH=%d WINDOW=%d",
          LIVE_TEST_MAX_SAMPLES, LIVE_TEST_BATCH_SIZE, LIVE_TEST_INFER_WINDOW);

    g_ctx.write_buf = (uint8_t *)osal_malloc(LIVE_TEST_MAX_SAMPLES * 6);
    g_ctx.csv_line  = (char *)osal_malloc(LIVE_TEST_CSV_LINE_SIZE);

    if (!g_ctx.write_buf || !g_ctx.csv_line) {
        log_e("Memory allocation failed");
        return;
    }
    log_i("Memory allocated: write_buf=%dKB csv_line=%dB",
          LIVE_TEST_MAX_SAMPLES * 6 / 1024, LIVE_TEST_CSV_LINE_SIZE);

    live_test_scan_trials();

    if (live_test_mpu6050_init() != 0) {
        log_e("MPU6050 init failed");
        return;
    }

    g_ctx.sem = osal_sem_create("live_sem", 0, 0);
    if (g_ctx.sem == NULL) {
        log_e("Semaphore creation failed");
        return;
    }

    g_ctx.task = osal_task_create("livetask", live_test_task, NULL,
                                   4096, 10, 20);
    if (g_ctx.task == NULL) {
        log_e("Task creation failed");
        return;
    }
    osal_task_startup(g_ctx.task);
    log_i("=== Live Test Ready ===");
}

#endif /* LIVE_TEST_MODE */

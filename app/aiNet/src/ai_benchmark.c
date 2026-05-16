#ifdef AI_BENCHMARK_MODE

#define LOG_TAG "BENCH"
#define LOG_LVL ELOG_LVL_DEBUG
#include "elog.h"

#include "ai_benchmark.h"
#include "app_x-cube-ai.h"
#include "fatfs_service.h"
#include "../../cdc_msc/usb_state.h"
#include "osal.h"
#include <string.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>

#define BENCHMARK_DIR       "/benchmark"
#define BENCHMARK_INPUT     "/benchmark/benchmark_data.bin"
#define BENCHMARK_OUTPUT    "/benchmark/benchmark_results.csv"
#define BIN_MAGIC           0x4D424446
#define BIN_VERSION         1
#define FEATURES_DIM        1200
#define SAMPLE_BUF_SIZE     1202
#define INFER_BUF_FLOATS    1200
#define LINE_BUF_SIZE       256
#define HEADER_BUF_SIZE     24

static osal_task_t bench_task = NULL;

static int bench_ensure_dir(void)
{
    if (!fatfs_service_exists(BENCHMARK_DIR)) {
        fatfs_err_t err = fatfs_service_mkdir(BENCHMARK_DIR);
        if (err != FATFS_OK) {
            log_e("Failed to create %s: %d", BENCHMARK_DIR, err);
            return -1;
        }
    }
    return 0;
}

static int bench_read_header(int32_t fh, uint32_t *num_samples)
{
    uint8_t header[HEADER_BUF_SIZE];
    int32_t n = fatfs_service_read(fh, header, HEADER_BUF_SIZE);
    if (n != HEADER_BUF_SIZE) {
        log_e("Failed to read header: got %ld bytes", (long)n);
        return -1;
    }

    uint32_t magic = *(uint32_t *)(header + 0);
    uint32_t version = *(uint32_t *)(header + 4);
    uint32_t samples = *(uint32_t *)(header + 8);
    uint32_t feat_dim = *(uint32_t *)(header + 12);

    if (magic != BIN_MAGIC) {
        log_e("Bad magic: 0x%08lX, expected 0x%08X", (unsigned long)magic, BIN_MAGIC);
        return -1;
    }
    if (version != BIN_VERSION) {
        log_e("Unsupported version: %lu", (unsigned long)version);
        return -1;
    }
    if (feat_dim != FEATURES_DIM || samples == 0) {
        log_e("Invalid header: samples=%lu, dim=%lu", (unsigned long)samples, (unsigned long)feat_dim);
        return -1;
    }

    *num_samples = samples;
    log_i("File header OK: %lu samples, %lu features", (unsigned long)samples, (unsigned long)feat_dim);
    return 0;
}

static void bench_print_results(int *predictions, int *true_labels,
                                uint32_t *time_ms_arr, uint32_t num_samples)
{
    uint32_t correct = 0;
    uint32_t cm[2][2] = {{0, 0}, {0, 0}};
    uint32_t total_time = 0, min_time = UINT32_MAX, max_time = 0;
    float sum_time2 = 0.0f;

    for (uint32_t i = 0; i < num_samples; i++) {
        int t = true_labels[i];
        int p = predictions[i];
        cm[t][p]++;
        if (t == p) correct++;

        uint32_t t_ms = time_ms_arr[i];
        total_time += t_ms;
        if (t_ms < min_time) min_time = t_ms;
        if (t_ms > max_time) max_time = t_ms;
        sum_time2 += (float)t_ms * (float)t_ms;
    }

    float avg = (float)total_time / num_samples;
    float var = (sum_time2 / num_samples) - (avg * avg);
    float std = (var > 0.0f) ? sqrtf(var) : 0.0f;

    log_i("=== Benchmark Complete ===");
    log_i("Accuracy: %.2f%% (%lu/%lu)", 100.0f * correct / num_samples,
          (unsigned long)correct, (unsigned long)num_samples);

    int tp = cm[0][0], fn = cm[0][1], fp = cm[1][0], tn = cm[1][1];

    float prec = (tp + fp > 0) ? (100.0f * tp / (tp + fp)) : 0.0f;
    float rec  = (tp + fn > 0) ? (100.0f * tp / (tp + fn)) : 0.0f;
    float f1   = (tp > 0) ? (200.0f * tp / (2 * tp + fp + fn)) : 0.0f;

    log_i("Precision: %.2f%%", prec);
    log_i("Recall:    %.2f%%", rec);
    log_i("F1-Score:  %.2f%%", f1);

    log_i("Confusion Matrix:");
    log_i("               Pred Fall   Pred Non-Fall");
    log_i("  True Fall        %-4d          %-4d", cm[0][0], cm[0][1]);
    log_i("  True Non-Fall     %-4d          %-4d", cm[1][0], cm[1][1]);

    log_i("Inference Time:");
    log_i("  min=%.1fms  avg=%.1fms  max=%.1fms  std=%.1fms",
          (float)min_time, avg, (float)max_time, std);

    log_i("Results saved to %s", BENCHMARK_OUTPUT);
}

void ai_benchmark_task(void *param)
{
    (void)param;
    log_i("=== AI Benchmark Started ===");
    log_i("Input:  %s", BENCHMARK_INPUT);
    log_i("Output: %s", BENCHMARK_OUTPUT);

    if (bench_ensure_dir() != 0) {
        return;
    }

    if (usb_state_is_connected()) {
        log_w("USB is connected, waiting for disconnect before running benchmark");
        return;
    }

    int32_t fh_input = fatfs_service_open(BENCHMARK_INPUT, FATFS_MODE_READ);
    if (fh_input < 0) {
        log_e("Cannot open input file: %ld", (long)fh_input);
        return;
    }

    uint32_t num_samples = 0;
    if (bench_read_header(fh_input, &num_samples) != 0) {
        fatfs_service_close(fh_input);
        return;
    }

    int32_t fh_output = fatfs_service_open(BENCHMARK_OUTPUT, FATFS_MODE_WRITE);
    if (fh_output < 0) {
        log_e("Cannot create output file: %ld", (long)fh_output);
        fatfs_service_close(fh_input);
        return;
    }

    const char *csv_header = "sample_index,true_label,predicted_label,is_correct,"
                             "logit_fall,logit_nonfall,prob_fall,prob_nonfall,infer_ms\n";
    int32_t wret = fatfs_service_write(fh_output, csv_header, strlen(csv_header));
    if (wret != (int32_t)strlen(csv_header)) {
        log_e("Failed to write CSV header: %ld", (long)wret);
        fatfs_service_close(fh_input);
        fatfs_service_close(fh_output);
        return;
    }

    static uint8_t sample_buf[SAMPLE_BUF_SIZE];
    static float input_buf[INFER_BUF_FLOATS];
    float logits[2];

    int *predictions = NULL;
    int *true_labels = NULL;
    float *prob_fall_arr = NULL;
    uint32_t *time_ms_arr = NULL;

    predictions  = (int *)osal_malloc(num_samples * sizeof(int));
    true_labels  = (int *)osal_malloc(num_samples * sizeof(int));
    prob_fall_arr = (float *)osal_malloc(num_samples * sizeof(float));
    time_ms_arr  = (uint32_t *)osal_malloc(num_samples * sizeof(uint32_t));

    if (!predictions || !true_labels || !prob_fall_arr || !time_ms_arr) {
        log_e("Memory allocation failed");
        osal_free(predictions);
        osal_free(true_labels);
        osal_free(prob_fall_arr);
        osal_free(time_ms_arr);
        fatfs_service_close(fh_input);
        fatfs_service_close(fh_output);
        return;
    }

    for (uint32_t i = 0; i < num_samples; i++) {
        int32_t n = fatfs_service_read(fh_input, sample_buf, SAMPLE_BUF_SIZE);
        if (n != SAMPLE_BUF_SIZE) {
            log_e("Read error at sample %lu: got %ld bytes", (unsigned long)i, (long)n);
            break;
        }

        for (int j = 0; j < INFER_BUF_FLOATS; j++) {
            input_buf[j] = (float)sample_buf[j];
        }

        uint16_t label = *(uint16_t *)(sample_buf + FEATURES_DIM);

        osal_enter_critical();
        osal_tick_t t0 = osal_tick_get();
        int ret = ai_run_direct(input_buf, logits);
        osal_tick_t t1 = osal_tick_get();
        osal_exit_critical();

        if (ret != 0) {
            log_e("Inference failed at sample %lu", (unsigned long)i);
            continue;
        }

        uint32_t infer_tick = (uint32_t)(t1 - t0);

        float max_logit = (logits[0] > logits[1]) ? logits[0] : logits[1];
        float exp0 = expf(logits[0] - max_logit);
        float exp1 = expf(logits[1] - max_logit);
        float sum = exp0 + exp1;
        float prob[2];
        prob[0] = exp0 / sum;
        prob[1] = exp1 / sum;

        int pred = (prob[0] > prob[1]) ? 0 : 1;
        int is_correct = (pred == (int)label) ? 1 : 0;

        predictions[i] = pred;
        true_labels[i] = (int)label;
        prob_fall_arr[i] = prob[0];
        time_ms_arr[i] = infer_tick;

        char line_buf[LINE_BUF_SIZE];
        int line_len = snprintf(line_buf, sizeof(line_buf),
            "%lu,%d,%d,%d,%.4f,%.4f,%.4f,%.4f,%lu\n",
            (unsigned long)i, (int)label, pred, is_correct,
            logits[0], logits[1], prob[0], prob[1], (unsigned long)infer_tick);

        if (line_len > 0 && line_len < (int)sizeof(line_buf)) {
            fatfs_service_write(fh_output, line_buf, line_len);
        }

        if ((i % 10) == 0) {
            log_i("[%3lu/%lu] label=%d pred=%d prob_fall=%.4f %s  %lums",
                   (unsigned long)i, (unsigned long)num_samples,
                   (int)label, pred, prob[0],
                   is_correct ? "OK" : "MISMATCH",
                   (unsigned long)infer_tick);
        }
    }

    fatfs_service_close(fh_input);
    fatfs_err_t close_err = fatfs_service_close(fh_output);
    if (close_err != FATFS_OK) {
        log_w("close output error %d", close_err);
    }
    fatfs_service_sync();

    bench_print_results(predictions, true_labels, time_ms_arr, num_samples);

    osal_free(predictions);
    osal_free(true_labels);
    osal_free(prob_fall_arr);
    osal_free(time_ms_arr);

    log_i("=== Benchmark Finished ===");
}

void ai_benchmark_task_init(void)
{
    bench_task = osal_task_create("benchtask", ai_benchmark_task, NULL, 4096, 10, 20);
    if (bench_task == NULL) {
        log_e("Failed to create benchmark task");
        return;
    }
    osal_task_startup(bench_task);
}

#endif
